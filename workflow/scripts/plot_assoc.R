logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

# temporarily remove because of import conflicts
# snakemake@source("util/setup.R")
# snakemake@source("util/io.R")
library(ggplot2)
library(dplyr)
library(magrittr)
library(RColorBrewer)

read_metal <- function(
    x,
    header = TRUE,
    colClasses = c(MarkerName = "character", Allele1 = "factor",
                   Allele2 = "factor", Effect = "numeric",
                   StdErr = "numeric", "P-value" = "numeric",
                   Direction = "character"),
    ...
) {
    read.table(x, header = header, colClasses = colClasses, ...) |>
        rename_with(tolower) |>
        rename(annotation_id = markername, a1 = allele1, a2 = allele2,
                      beta = effect, stderr = stderror, p = "p-value")
}

read_plink_assoc <- function(
    x,
    header = TRUE,
    colClasses = c(CHR = "factor", SNP = "character", BP = "numeric",
                   A1 = "factor", NMISS = "integer", L95 = "numeric",
                   U95 = "numeric", STAT = "numeric", P = "numeric"),
    ...
) {
    read.table(x, header = header, colClasses = colClasses, ...) |>
        rename_with(tolower) |>
        rename(chr = chr, annotation_id = snp, pos = bp) |>
        mutate(across(
            chr, 
            ~ gsub("chr", "", .x, ignore.case = TRUE) |> as.integer()
        ))
}

ext <- tools::file_ext(input$assoc)
if (ext %in% c("assoc", "linear", "logistic")) {
    assoc <- read_plink_assoc(input$assoc)
} else if (ext == "tbl") {
    assoc <- read_metal(input$assoc)
} else if (ext == "rds") {
    assoc <- readRDS(input$assoc)
} else {
    stop("GWAS results must be in PLINK, METAL or MetaSoft format, or pre-formatted and saved as an RDS file")
}

assoc <- filter(assoc, !is.na(p)) %>%
    filter(chr <= 22) %>%
    mutate(x = pos, y = -1 * log10(p), clr = as.character(chr %% params$nclr))
n_test <- nrow(assoc)

for (i in 1:(max(assoc$chr) - 1)) {
    j <- i + 1
    start_pos <- filter(assoc, chr == i)$x %>% max()
    assoc$x[assoc$chr == j] <- assoc$pos[assoc$chr == j] + start_pos + params$mxpad 
}

assoc_tmp <- filter(assoc, p <= params$sparse_thresh)
assoc_sparse <- filter(assoc, p > params$sparse_thresh) %>%
    slice_sample(prop = 0.3)

assoc_plot <- rbind(assoc_tmp, assoc_sparse)

dat_xlab <- group_by(assoc, chr) %>%
    summarize(x = (min(x) + max(x)) / 2) %>%
    mutate(y = -0.1)

gman <- ggplot(assoc_plot, aes(x = x, y = y, color = clr)) +
    geom_point() +
    scale_color_brewer(palette = params$palette) +
    xlab("Chromosome/position") +
    ylab(expression(-log[10](p))) +
    theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(),
          legend.position = "none") +
    geom_text(data = dat_xlab, aes(label = chr), color = "black") +
    ggtitle(params$mtitle, sprintf("n tests: %.2g", n_test))

if (!is.null(params$annot_region)) {
    annot_region <- as.data.frame(params$annot_region)
    annot_region$x <- annot_region$y <- NA
    for (i in 1:nrow(annot_region)) {
        region <- annot_region[i, ]
        lead_snp <- filter(assoc, chr == region$chr,
                           between(pos, region$start, region$end)) %>%
            slice_min(p, n = 1) %>%
            slice_head(n = 1)
        annot_region$x[i] <- lead_snp$x
        annot_region$y[i] <- lead_snp$y
    }
    gman <- gman +
        geom_point(data = annot_region, color = "black", size = 1) +
        geom_text(data = annot_region, aes(label = lab), color = "black",
                  nudge_y = -0.07)
    # TO-DO: add legend describing annotations
}

for (i in params$hline) {
    if (max(assoc$y > i -0.5)) {
        gman <- gman +
            geom_hline(yintercept = i, linetype = "dashed", color = "red")
    }
}

ggsave(output$manhattan, gman, width = params$mwidth, height = params$mheight,
       units = params$munit)

lambda <- median(qchisq(assoc$p, df = 1, lower.tail = FALSE)) / qchisq(0.5, df = 1)
qq <- data.frame(
    obs = sort(assoc$y, decreasing = TRUE),
    exp = -log10(ppoints(nrow(assoc)))
)
gqq <- ggplot(qq, aes(x = exp, y = obs)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0) +
    labs(title = "Q-Q",
         subtitle = bquote(lambda[50] == .(sprintf("%.3f", lambda))))
ggsave(output$qq, gqq, width = 10, heigh = 10, units = "in")
