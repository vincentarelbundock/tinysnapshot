% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expect_snapshot_print.R
\name{expect_snapshot_print}
\alias{expect_snapshot_print}
\title{Test if printed output matches a target printout}
\usage{
expect_snapshot_print(
  current,
  label,
  mode = getOption("tinysnapshot_mode", default = "unified"),
  format = getOption("tinysnapshot_format", default = "ansi256"),
  ignore_white_space = getOption("tinysnapshot_ignore_white_space", default = FALSE),
  ...
)
}
\arguments{
\item{current}{an object which returns text to the console when calling \verb{print(x})`}

\item{label}{a string to identify the snapshot (alpha-numeric, hyphens, or underscores). Each plot in the test suite must have a unique label.}

\item{mode}{"unified", "sidebyside", "context", or "auto". See \code{?diffobj::diffPrint}}

\item{format}{"raw", "ansi8", "ansi256", "html", or "auto". See \code{?diffobj::diffPrint}}

\item{ignore_white_space}{\code{TRUE} to ignore horizontal white space and empty lines.}

\item{...}{Additional arguments are passed to \code{diffobj::diffPrint()}}
}
\value{
A \code{tinytest} object. A \code{tinytest} object is a \code{logical} with attributes holding information about the test that was run
}
\description{
This expectation can be used with \code{tinytest} to check if the new plot matches
a target plot.

When the expectation is checked for the first time, the expectation fails and
a reference text file is saved to the \verb{inst/tinytest/_tinysnapshot} folder.

To update a snapshot, delete the reference file from the \verb{_tinysnapshot}
folder and run the test suite again.

See the package README file or website for detailed examples.
}
