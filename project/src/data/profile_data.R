# profile_data.R
#
# Generate compact, human- and AI-readable profiles for datasets stored in:
#   project/volume/data/raw/
#
# Profiles are written to:
#   project/volume/data/profiles/
#
# Assumptions:
# - Course datasets are small enough to load fully into RAM.
# - Raw data are never modified.
# - Profiles should describe structure without becoming full EDA reports.
# - Reasonably enumerable categorical variables should list all observed categories.
#
# Dependency:
#   data.table
#
# Run from the repository root:
#   Rscript project/src/data/profile_data.R

suppressPackageStartupMessages({
  library(data.table)
})

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

RAW_DIR <- "project/volume/data/raw"
PROFILE_DIR <- "project/volume/data/profiles"

MAX_ENUM_LEVELS_CHARACTER <- 50L
MAX_ENUM_LEVELS_NUMERIC <- 20L

HIGH_UNIQUENESS_RATIO <- 0.80
ID_UNIQUENESS_RATIO <- 0.95
MIN_ID_UNIQUE <- 20L

LONG_TEXT_MEAN_LENGTH <- 40
N_EXAMPLES <- 5L


# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

ensure_directories <- function() {
  if (!dir.exists(RAW_DIR)) {
    stop(
      "Raw data directory does not exist: ", RAW_DIR,
      "\nRun this script from the repository root."
    )
  }

  if (!dir.exists(PROFILE_DIR)) {
    dir.create(PROFILE_DIR, recursive = TRUE)
  }
}


read_dataset <- function(path) {
  lower <- tolower(path)

  if (grepl("\\.rds$", lower)) {
    obj <- readRDS(path)

    if (!is.data.frame(obj)) {
      stop("RDS file does not contain a data.frame/data.table: ", path)
    }

    return(as.data.table(obj))
  }

  if (grepl("\\.(csv|csv\\.gz|tsv|tsv\\.gz|txt|txt\\.gz)$", lower)) {
    return(fread(path))
  }

  stop("Unsupported file type: ", path)
}


format_bytes <- function(bytes) {
  units <- c("B", "KB", "MB", "GB", "TB")
  i <- 1L
  value <- bytes

  while (value >= 1024 && i < length(units)) {
    value <- value / 1024
    i <- i + 1L
  }

  sprintf("%.2f %s", value, units[i])
}


escape_md <- function(x) {
  x <- as.character(x)
  x <- gsub("\\|", "\\\\|", x)
  x <- gsub("\n", " ", x, fixed = TRUE)
  x <- gsub("\r", " ", x, fixed = TRUE)
  trimws(x)
}


truncate_value <- function(x, width = 80L) {
  x <- escape_md(x)
  too_long <- nchar(x, type = "width") > width

  x[too_long] <- paste0(
    substr(x[too_long], 1L, width - 3L),
    "..."
  )

  x
}


r_type_label <- function(x) {
  if (inherits(x, "POSIXct") || inherits(x, "POSIXt")) return("datetime")
  if (inherits(x, "Date")) return("date")
  if (is.factor(x)) return("factor")
  if (is.logical(x)) return("logical")
  if (is.integer(x)) return("integer")
  if (is.numeric(x)) return("numeric")
  if (is.character(x)) return("character")

  paste(class(x), collapse = "/")
}


nonmissing_unique <- function(x) {
  unique(x[!is.na(x)])
}


safe_unique_count <- function(x) {
  uniqueN(x, na.rm = TRUE)
}


looks_like_identifier <- function(n_unique, n_nonmissing) {
  if (n_nonmissing == 0L || n_unique < MIN_ID_UNIQUE) {
    return(FALSE)
  }

  (n_unique / n_nonmissing) >= ID_UNIQUENESS_RATIO
}


looks_like_long_text <- function(x) {
  if (!is.character(x)) {
    return(FALSE)
  }

  vals <- x[!is.na(x)]

  if (!length(vals)) {
    return(FALSE)
  }

  mean(nchar(vals), na.rm = TRUE) >= LONG_TEXT_MEAN_LENGTH
}


should_enumerate <- function(
    x,
    n_unique,
    n_nonmissing,
    likely_id,
    long_text
) {
  if (n_nonmissing == 0L || n_unique == 0L) {
    return(FALSE)
  }

  # Factors and logicals are categorical by construction.
  if (is.factor(x) || is.logical(x)) {
    return(n_unique <= MAX_ENUM_LEVELS_CHARACTER)
  }

  # Do not dump long lists that strongly resemble identifiers or prose.
  if (likely_id || long_text) {
    return(FALSE)
  }

  uniqueness_ratio <- n_unique / n_nonmissing

  if (is.character(x)) {
    return(
      n_unique <= MAX_ENUM_LEVELS_CHARACTER &&
        (
          uniqueness_ratio <= HIGH_UNIQUENESS_RATIO ||
            n_unique <= 10L
        )
    )
  }

  if (is.integer(x) || is.numeric(x)) {
    return(
      n_unique <= MAX_ENUM_LEVELS_NUMERIC &&
        (
          uniqueness_ratio <= 0.20 ||
            n_unique <= 10L
        )
    )
  }

  FALSE
}


format_examples <- function(x, n = N_EXAMPLES) {
  vals <- nonmissing_unique(x)

  if (!length(vals)) {
    return("—")
  }

  vals <- head(vals, n)
  vals <- truncate_value(vals)

  paste0("`", vals, "`", collapse = ", ")
}


format_levels <- function(x) {
  vals <- nonmissing_unique(x)

  if (!length(vals)) {
    return(character())
  }

  vals <- sort(as.character(vals), na.last = TRUE)

  paste0(
    "- `",
    truncate_value(vals, width = 120L),
    "`"
  )
}


numeric_summary <- function(x) {
  vals <- x[!is.na(x)]

  if (!length(vals)) {
    return(NULL)
  }

  qs <- quantile(
    vals,
    probs = c(0, 0.25, 0.5, 0.75, 1),
    na.rm = TRUE,
    names = FALSE,
    type = 7
  )

  list(
    min = qs[1],
    q1 = qs[2],
    median = qs[3],
    mean = mean(vals),
    q3 = qs[4],
    max = qs[5]
  )
}


fmt_num <- function(x) {
  if (is.na(x)) {
    return("NA")
  }

  format(
    signif(x, 6),
    scientific = FALSE,
    trim = TRUE,
    big.mark = ","
  )
}


column_profile <- function(x, name, n_rows) {
  n_missing <- sum(is.na(x))
  n_nonmissing <- n_rows - n_missing
  n_unique <- safe_unique_count(x)

  missing_pct <- if (n_rows == 0L) {
    0
  } else {
    100 * n_missing / n_rows
  }

  uniqueness_ratio <- if (n_nonmissing == 0L) {
    NA_real_
  } else {
    n_unique / n_nonmissing
  }

  likely_id <- looks_like_identifier(
    n_unique,
    n_nonmissing
  )

  long_text <- looks_like_long_text(x)

  enumerate <- should_enumerate(
    x = x,
    n_unique = n_unique,
    n_nonmissing = n_nonmissing,
    likely_id = likely_id,
    long_text = long_text
  )

  flags <- character()

  if (n_unique == 0L) {
    flags <- c(flags, "all missing")
  }

  if (n_unique == 1L && n_nonmissing > 0L) {
    flags <- c(flags, "constant")
  }

  if (missing_pct >= 50) {
    flags <- c(flags, "high missingness")
  }

  if (likely_id) {
    flags <- c(
      flags,
      "likely identifier / near-unique"
    )
  }

  if (long_text) {
    flags <- c(
      flags,
      "likely free text"
    )
  }

  list(
    name = name,
    type = r_type_label(x),
    missing = n_missing,
    missing_pct = missing_pct,
    unique = n_unique,
    unique_ratio = uniqueness_ratio,
    examples = format_examples(x),
    enumerate = enumerate,
    levels = if (enumerate) {
      format_levels(x)
    } else {
      character()
    },
    numeric = if (is.numeric(x)) {
      numeric_summary(x)
    } else {
      NULL
    },
    flags = flags
  )
}


profile_dataset <- function(path) {
  dt <- read_dataset(path)

  n_rows <- nrow(dt)
  n_cols <- ncol(dt)

  columns <- lapply(
    names(dt),
    function(nm) {
      column_profile(
        dt[[nm]],
        nm,
        n_rows
      )
    }
  )

  list(
    path = path,
    file_name = basename(path),
    file_size = file.info(path)$size,
    rows = n_rows,
    columns_n = n_cols,
    duplicate_rows = if (n_rows > 0L) {
      n_rows - uniqueN(dt)
    } else {
      0L
    },
    columns = columns
  )
}


profile_output_name <- function(path) {
  nm <- basename(path)

  nm <- sub(
    "\\.gz$",
    "",
    nm,
    ignore.case = TRUE
  )

  nm <- sub(
    "\\.(csv|tsv|txt|rds)$",
    "",
    nm,
    ignore.case = TRUE
  )

  file.path(
    PROFILE_DIR,
    paste0(nm, "_profile.md")
  )
}


write_profile <- function(profile, output_path) {
  con <- file(
    output_path,
    open = "wt",
    encoding = "UTF-8"
  )

  on.exit(
    close(con),
    add = TRUE
  )

  w <- function(...) {
    writeLines(
      paste0(...),
      con
    )
  }

  w(
    "# Data Profile: `",
    profile$file_name,
    "`"
  )

  w("")

  w(
    "> Generated automatically by ",
    "`project/src/data/profile_data.R`."
  )

  w(
    "> Raw data were inspected but not modified."
  )

  w("")

  w("## File Summary")
  w("")

  w(
    "- **Path:** `",
    profile$path,
    "`"
  )

  w(
    "- **File size:** ",
    format_bytes(profile$file_size)
  )

  w(
    "- **Rows:** ",
    format(
      profile$rows,
      big.mark = ","
    )
  )

  w(
    "- **Columns:** ",
    format(
      profile$columns_n,
      big.mark = ","
    )
  )

  w(
    "- **Exact duplicate rows:** ",
    format(
      profile$duplicate_rows,
      big.mark = ","
    )
  )

  w("")

  w("## Column Overview")
  w("")

  w(
    "| Column | R type | Missing | Missing % | ",
    "Unique | Example values | Flags |"
  )

  w(
    "|---|---|---:|---:|---:|---|---|"
  )

  for (col in profile$columns) {
    flags <- if (length(col$flags)) {
      paste(
        col$flags,
        collapse = "; "
      )
    } else {
      "—"
    }

    w(
      "| `",
      escape_md(col$name),
      "` | ",
      escape_md(col$type),
      " | ",
      format(
        col$missing,
        big.mark = ","
      ),
      " | ",
      sprintf(
        "%.2f%%",
        col$missing_pct
      ),
      " | ",
      format(
        col$unique,
        big.mark = ","
      ),
      " | ",
      col$examples,
      " | ",
      escape_md(flags),
      " |"
    )
  }

  w("")
  w("## Column Details")
  w("")

  for (col in profile$columns) {
    w(
      "### `",
      escape_md(col$name),
      "`"
    )

    w("")

    w(
      "- **R type:** ",
      col$type
    )

    w(
      "- **Missing:** ",
      format(
        col$missing,
        big.mark = ","
      ),
      " (",
      sprintf(
        "%.2f%%",
        col$missing_pct
      ),
      ")"
    )

    w(
      "- **Unique non-missing values:** ",
      format(
        col$unique,
        big.mark = ","
      )
    )

    if (!is.na(col$unique_ratio)) {
      w(
        "- **Uniqueness ratio:** ",
        sprintf(
          "%.3f",
          col$unique_ratio
        )
      )
    }

    if (length(col$flags)) {
      w(
        "- **Flags:** ",
        paste(
          col$flags,
          collapse = "; "
        )
      )
    }

    if (!is.null(col$numeric)) {
      s <- col$numeric

      w("- **Numeric summary:**")
      w("  - Min: ", fmt_num(s$min))
      w("  - Q1: ", fmt_num(s$q1))
      w("  - Median: ", fmt_num(s$median))
      w("  - Mean: ", fmt_num(s$mean))
      w("  - Q3: ", fmt_num(s$q3))
      w("  - Max: ", fmt_num(s$max))
    }

    if (col$enumerate) {
      w(
        "- **Observed categories / values:**"
      )

      for (lev in col$levels) {
        w(
          "  ",
          lev
        )
      }
    } else {
      w(
        "- **Representative values:** ",
        col$examples
      )
    }

    w("")
  }

  w("## Interpretation Notes")
  w("")

  w(
    "- Category/value enumeration is heuristic. ",
    "A variable is enumerated when its observed ",
    "value set is small enough to be useful and ",
    "it does not strongly resemble an identifier ",
    "or free-text field."
  )

  w(
    "- Numeric variables are treated more ",
    "conservatively than character variables ",
    "when deciding whether to enumerate values."
  )

  w(
    "- Flags such as `likely identifier / near-unique` ",
    "and `likely free text` are heuristics, not ",
    "semantic guarantees."
  )

  w(
    "- This profile describes dataset structure ",
    "and basic distributions. It is not a substitute ",
    "for exploratory data analysis, visualization, ",
    "validation, or statistical reasoning."
  )
}


# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

ensure_directories()

files <- list.files(
  RAW_DIR,
  full.names = TRUE,
  recursive = FALSE,
  pattern = paste0(
    "\\.",
    "(csv|csv\\.gz|tsv|tsv\\.gz|",
    "txt|txt\\.gz|rds)$"
  ),
  ignore.case = TRUE
)

if (!length(files)) {
  message(
    "No supported datasets found in ",
    RAW_DIR
  )

  message(
    paste(
      "Supported formats:",
      "CSV, CSV.GZ, TSV, TSV.GZ,",
      "TXT, TXT.GZ, RDS"
    )
  )

  quit(
    save = "no",
    status = 0
  )
}

message(
  "Profiling ",
  length(files),
  " dataset(s)..."
)

for (path in files) {
  message(
    "  - ",
    basename(path)
  )

  profile <- profile_dataset(path)

  output <- profile_output_name(path)

  write_profile(
    profile,
    output
  )

  message(
    "    -> ",
    output
  )
}

message("Done.")
