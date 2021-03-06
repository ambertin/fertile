#' @rdname check_path
#' @export
#' @inheritParams fs::path_has_parent
#' @importFrom purrr map_lgl
#' @return A logical vector
#' @examples
#' is_path_portable(c(tempfile(), "~/.Rprofile", "../data.csv"))
is_path_portable <- function(path, parent = ".") {
  purrr::map_lgl(path, is_path_is_portable_, parent = parent)
}

#' @inheritParams fs::path_has_parent

is_path_is_portable_ <- function(path, parent = ".") {
  path_has_parent(path, parent) &
    identical(
      path_rel(path, start = parent),
      path_norm(path(path))
    )
}

#' @rdname check_path
#' @export

check_path_is_portable <- function(path, parent = ".", strict = TRUE) {
  message("Checking for paths outside project directory...")
  bad <- path[!is_path_portable(path, parent)]
  out <- tibble::tibble(
    path = bad,
    problem = "Path is not contained within the project directory",
    solution = "Move the file and/or use a relative path. See ?fs::path_rel()"
  )

  text <- "Detected paths that lead outside the project directory. Such paths are not reproducible and will likely only work on your computer."

  if (strict && nrow(out) > 0) {
    rlang::abort(text)
  }
  out
}

#' @rdname check_path
#' @param ... For behind the scenes behavior by fertile. Please ignore.
#' @export
#' @keywords internal

check_path_is_portable_shim <- function(path, parent = ".", strict = TRUE, ...) {
  message("Checking for paths outside project directory...")
  bad <- path[!is_path_portable(path, parent)]
  out <- tibble::tibble(
    path = bad,
    problem = "Path is not contained within the project directory",
    solution = "Move the file and/or use a relative path. See ?fs::path_rel()"
  )

  text_1 <- "Detected paths that lead outside the project directory. Such paths are not reproducible and will likely only work on your computer."
  text_2 <- " If you would like to continue anyway, please execute the following command: "

  if (strict && nrow(out) > 0) {
    rlang::abort(paste0(text_1, text_2, ..., "('", path, "')"))
  }
  out
}

#' @rdname check_path
#' @export

check_path_absolute <- function(path, strict = TRUE) {
  message("Checking for absolute paths...")
  call <- as.character(match.call())[2]
  if (grepl("^here+", call) == TRUE) {
    bad <- path[!is_absolute_path(path)]
  } else {
    bad <- path[is_absolute_path(path)]
  }
  out <- tibble::tibble(
    path = bad,
    problem = "Absolute paths will likely only work on your computer",
    solution = "Use a relative path. See ?path_rel()"
  )


  text <- "Detected absolute paths. Absolute paths are not reproducible and will likely only work on your computer."


  if (strict && nrow(out) > 0) {
    rlang::abort(text)
  }
  out
}

#' @rdname check_path
#' @param ... For behind the scenes behavior by fertile. Please ignore.
#' @export
#' @keywords internal

check_path_absolute_shim <- function(path, strict = TRUE, ...) {
  message("Checking for absolute paths...")
  call <- as.character(match.call())[2]
  if (grepl("^here+", call) == TRUE) {
    bad <- path[!is_absolute_path(path)]
  } else {
    bad <- path[is_absolute_path(path)]
  }
  out <- tibble::tibble(
    path = bad,
    problem = "Absolute paths will likely only work on your computer",
    solution = "Use a relative path. See ?path_rel()"
  )


  text_1 <- "Detected absolute paths. Absolute paths are not reproducible and will likely only work on your computer."
  text_2 <- " If you would like to continue anyway, please execute the following command: "



  if (strict && nrow(out) > 0) {
    rlang::abort(paste0(text_1, text_2, ..., "('", path, "')"))
  }
  out
}


#' Check paths for portability
#' @export
#' @param path a vector of paths
#' @param ... For behind the scenes behavior by fertile. Please ignore.
#' @param strict logical indicating whether you want to stop on errors
#' @description Check paths for a variety of maladies
#' @examples
#' \dontrun{
#' check_path(tempfile())
#' }
#' check_path(tempfile(), strict = FALSE)
#' check_path(c("data.csv", "~/.Rprofile"), strict = FALSE)
check_path <- function(path, parent = ".", strict = TRUE) {
  dplyr::bind_rows(
    check_path_absolute(path, strict),
    check_path_is_portable(path, parent, strict)
  )
}

#' Check paths for portability
#' @export
#' @param path a vector of paths
#' @param ... For behind the scenes behavior by fertile. Please ignore.
#' @param strict logical indicating whether you want to stop on errors
#' @description Check paths for a variety of maladies
#' @keywords internal


check_path_shim <- function(path, parent = ".", strict = TRUE, ...) {
  dplyr::bind_rows(
    check_path_absolute_shim(path, strict, ...),
    check_path_is_portable_shim(path, parent, strict, ...)
  )
}

#' Runs check_path, but will only work interactively and cannot be run by fertile in the background.
#' @keywords internal
#' @param path Path you want to check
#' @export

check_path_safe <- function(path, ...) {
  if (Sys.getenv("FERTILE_RENDER_MODE") != TRUE) {
    check_path_shim(path, ...)
  }
}
