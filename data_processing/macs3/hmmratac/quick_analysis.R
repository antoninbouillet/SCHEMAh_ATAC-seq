library(tidyverse)
library(flextable)
library(ggpubr)
library(officer)
library(here)

rm(list = ls())

dir <- here()


samples = c("5a1", "5a2", "5a3", "C1", "C2", "C3", "dg1")

for (sample in samples) {
  
  print(paste0(sample, "_accessible_regions.narrowPeak"))
  s <- read.delim(paste0(dir, "/", sample, "/", sample, "_accessible_regions.narrowPeak"), header=F, sep="\t")
  
  s <-s %>% mutate(bases = V3 - V2,
                   ech = paste0(sample))
  if ( grepl("5a", s$ech[1]) ) {
    s <- s %>% mutate(test = "5aza")
  }
  else if ( grepl("C", s$ech[1]) ) {
    s <- s %>% mutate(test = "control")
  }
  else if ( grepl("dg", s$ech[1]) ) {
    s <- s %>% mutate(test = "dg3d")
  }
  else {s <- s %>% mutate(test = NA)} 
  
  assign(paste0("peaks_", sample), s)
  rm(s)
  
}

all_peaks <- rbind( peaks_5a1,
                    peaks_5a2,
                    peaks_5a3,
                    peaks_C1,
                    peaks_C2,
                    peaks_C3,
                    peaks_dg1)

all_peaks$test = factor(all_peaks$test, levels = c("control", "5aza", "dg3d"))
all_peaks$ech = factor(all_peaks$ech, levels = c("C1", "C2", "C3", "5a1", "5a2", "5a3", "dg1"))

all_peaks_sum <- all_peaks %>% group_by(ech, test) %>% summarize(sum_bases=sum(bases),
                                                                 nb_peaks=n(),
                                                                 mean_length=mean(bases),
                                                                 mean_score=mean(V5) )

all_peaks_sum$test = factor(all_peaks_sum$test, levels = c("control", "5aza", "dg3d"))

summary <- flextable(all_peaks_sum) %>% theme_zebra()

flextable::save_as_html(summary, path=file.path(dir, "hmmratac_quick_analysis_table.html") )


nbases <- ggplot(data=all_peaks_sum, aes(x=ech, y=sum_bases, fill=test)) +
  geom_col(width=0.4) +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(x="", title="nb. accessible bases") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D", "#EC7E70"))

comp  <- ggplot(data=all_peaks_sum %>% filter(test != "dg3d"), aes(x=test, y=sum_bases, fill=test)) +
  geom_boxplot(width=0.4) +
  stat_compare_means() +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10() +
  labs(x="", title="") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D"))

npeaks <- ggplot(data=all_peaks_sum, aes(x=ech, y=nb_peaks, fill=test))+
  geom_col(width=0.4) +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(x="", title="nb. of peaks") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D", "#EC7E70"))

lpeaks <- ggplot(data=all_peaks, aes(x=ech, y=bases, fill=test)) +
  geom_boxplot(width=0.4, outlier.size = 0.5) +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_log10() +
  labs(x="", title="peak length") +
  scale_fill_manual(values=c("#6D8CF0", "#F0D16D", "#EC7E70")) 

pdf(file = file.path(dir, "hmmratac_quick_analysis.pdf"))

ggarrange(nbases, comp, npeaks, lpeaks, common.legend = TRUE)

dev.off()
