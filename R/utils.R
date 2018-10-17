# stolen from
# https://github.com/tidyverse/tidyverse/blob/a720dcd73d9e3fc0ec86317bc0abaf8f0077e8bd/R/utils.R

#' @importFrom crayon bold
#' @importFrom cli rule

msg <- function(text) {
  cli::rule(
    left = crayon::bold(text),
    right = paste0("fertile ", package_version("fertile"))
  ) %>%
    text_col() %>%
    message()
}

#' @importFrom rstudioapi isAvailable hasFun getThemeInfo
#' @importFrom crayon white black

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)

}

#' @importFrom utils packageVersion
#' @importFrom crayon red

package_version <- function(x) {
  version <- as.character(unclass(utils::packageVersion(x))[[1]])

  if (length(version) > 3) {
    version[4:length(version)] <- crayon::red(as.character(version[4:length(version)]))
  }
  paste0(version, collapse = ".")
}

#' Utility function to create a copy of a project in a temp directory
#' @importFrom fs path dir_exists dir_delete dir_copy
#' @inheritParams fs::dir_exists
#' @export

sandbox <- function(path) {
  test_dir <- fs::path(tempdir(), fs::path_file(path))
  if (fs::dir_exists(test_dir)) {
    fs::dir_delete(test_dir)
  }
  fs::dir_copy(path, test_dir)
  return(test_dir)
}
