logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")

input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(ggplot2)
library(dplyr)
library(magrittr)
library(RColorBrewer)

if (is.null(params$sparse_thresh)) params$sparse_thresh <- 0.1

assoc <- read.table(input$assoc, header = TRUE) %>%
    filter(!is.na(P), CHR <= 22) %>%
    mutate(px = as.numeric(BP), neglogp = -1 * log10(P),
           clr = as.character(CHR %% 7))

# Create continuous x axis for Manhattan plot
x <- 1
while (x < 23) {
    start_pos <- filter(assoc, CHR == x)$px %>% max()
    x <- x + 1
    assoc$px[assoc$CHR == x] <- assoc$BP[assoc$CHR == x] + start_pos + 1e7
}

apoe_lead <- filter(assoc, CHR == 19, between(BP, 44850000, 44960000)) %>%
    slice_min(P, n = 1) %>%
    slice_head(n = 1) %>% # Return just one row if multiple rows have same P
    select(px, neglogp) %>%
    mutate(lab = "APOE")

dat_xlab <- group_by(assoc, CHR) %>%
    summarize(px = median(px)) %>%
    mutate(neglogp = -0.1)

assoc_tmp <- filter(assoc, P <= params$sparse_thresh)
assoc_sparse <- filter(assoc, P > params$sparse_thresh) %>%
    slice_sample(prop = 0.1)

assoc_plot <- rbind(assoc_tmp, assoc_sparse)

gmanh <- ggplot(assoc_plot, aes(x = px, y = neglogp, color = clr)) +
    geom_point() +
    scale_color_brewer(palette = "Set2") +
    xlab("") +
    ylab("-log10(P)") +
    theme(panel.margin.x = unit(0.2, "lines"), axis.ticks.x = element_blank(),
          axis.text.x = element_blank(), legend.position = "none") +
    geom_text(data = dat_xlab, aes(label = CHR), color = "black") +
    geom_point(data = apoe_lead, color = "black", fill = "white", size = 1,
               stroke = 0.1) +
    geom_text(data = apoe_lead, aes(label = lab), color = "black", hjust = 0,
              nudge_y = -0.05)

for (i in c(5, 7)) {
    if (max(assoc$neglogp > i -0.5)) {
        gmanh <- gmanh +
            geom_hline(yintercept = i, linetype = "dashed", color = "red")
    }
}

ggsave(output$manhattan, gmanh, width = 24, height = 10, units = "in")

lambda <- median(qchisq(assoc$P, df = 1, lower.tail = FALSE)) / qchisq(0.5, df = 1)
qq <- data.frame(
    obs = sort(assoc$neglogp, decreasing = TRUE),
    exp = -log10(ppoints(nrow(assoc)))
)
gqq <- ggplot(qq, aes(x = exp, y = obs)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0) +
    labs(title = "Q-Q", subtitle = sprintf("lambda-50: %.3f", lambda))
ggsave(output$qq, gqq, width = 10, heigh = 10, units = "in")
