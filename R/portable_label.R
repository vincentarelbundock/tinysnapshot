portable_label <- function(label, warn = TRUE) {
    regex <- "[^[:alnum:]|_|-]"
    out <- gsub(regex, "_", label)
    if (isTRUE(warn) && grepl(regex, label)) {
        msg <- 'The `label` must be a "portable" string with only alpha-numeric characters, hyphens, or underscores. Other characters were replaced by underscores:
        %s 
        %s'
        msg <- sprintf(msg, label, out)
        warning(msg, call. = TRUE)
    }
    return(out)
}