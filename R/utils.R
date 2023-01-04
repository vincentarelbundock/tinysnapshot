snapshot_label <- function(label) {
    regex <- "[^[:alnum:]|_|-]"
    out <- gsub(regex, "_", label)
    if (grepl(regex, label)) {
        msg <- 'The `label` argument must be a "portable" string with only alpha-numeric characters, hyphens, or underscores. Other characters were replaced by underscores:
        %s 
        %s'
        msg <- sprintf(msg, label, out)
        warning(msg, call. = TRUE)
    }

    return(out)
}