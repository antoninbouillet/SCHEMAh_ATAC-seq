library(tidyverse)
library(flextable)
library(ggpubr)
library(officer)
library(here)

rm(list = ls())

dir <- here()

samples = c("5aza", "control")

for (sample in samples) {
  
  print(paste0(sample, "_accessible_regions.narrowPeak"))
  s <- read.delim(paste0(dir, "/", sample, "_pool", "/", sample, "_accessible_regions.narrowPeak"), header=F, sep="\t")
  
  s <-s %>% mutate(bases = V3 - V2,
                   test = paste0(sample))
  assign(paste0("peaks_", sample), s)
  rm(s)
  
}

all_peaks <- rbind( peaks_5aza,
                    peaks_control )

all_peaks$test <- factor(all_peaks$test, levels = c("control", "5aza"))
  
all_peaks_sum <- all_peaks %>% group_by(test) %>% summarize(sum_bases=sum(bases),
                                                                 nb_peaks=n(),
                                                                 mean_length=mean(bases))

all_peaks_sum$test = factor(all_peaks_sum$test, levels = c("control", "5aza"))

summary <- flextable(all_peaks_sum) %>% theme_zebra()

flextable::save_as_html(summary, path=file.path(dir, "hmmratac_quick_analysis_pool_table.html") )


nbases <- ggplot(data=all_peaks_sum, aes(x=test, y=sum_bases, fill=test)) +
  geom_col(width=0.4) +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(x="", title="nb. accessible bases") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D"))

npeaks <- ggplot(data=all_peaks_sum, aes(x=test, y=nb_peaks, fill=test))+
  geom_col(width=0.4) +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(x="", title="nb. of peaks") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D"))

lpeaks <- ggplot(data=all_peaks, aes(x=test, y=bases, fill=test)) +
  geom_boxplot(width=0.4) +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10() +
  labs(x="", title="peak length") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D"))

pdf(file = file.path(dir, "hmmratac_quick_analysis_pool.pdf"))

ggarrange(nbases, npeaks, lpeaks, common.legend = TRUE)

dev.off()
