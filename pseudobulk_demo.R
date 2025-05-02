library("SingleCellExperiment")
library("SummarizedExperiment")
library("scran")


#Example from scran documentation
set.seed(1000)
library(scuttle)
sce <- mockSCE(ncells=1000)
sce$samples <- gl(8, 125) # Pretending we have 8 samples.

# Making up some clusters.
sce <- logNormCounts(sce)
clusters <- kmeans(t(logcounts(sce)), centers=3)$cluster

# Creating a set of pseudo-bulk profiles:
info <- DataFrame(sample=sce$samples, cluster=clusters)
pseudo <- aggregateAcrossCells(sce, info)

# Making up an experimental design for our 8 samples.
pseudo$DRUG <- gl(2,4)[pseudo$sample]

# DGE analysis:
out <- pseudoBulkDGE(pseudo,
   label=pseudo$cluster,
   condition=pseudo$DRUG,
   design=~DRUG,
   coef="DRUG2"
)


####################################################################
#Example for matching scripts using to spatialLIBD package
set.seed(1000)

# Define genes and total cells
n_genes <- 100
n_samples <- 8
n_domains <- 9

# Generate random number of cells per (sample, domain) between 2 and 20
cells_per_group <- sample(2:20, n_samples * n_domains, replace = TRUE)

# Total number of cells
total_cells <- sum(cells_per_group)
message("Total cells: ", total_cells)

# Make a counts matrix
counts <- matrix(rpois(n_genes * total_cells, lambda = 10), nrow = n_genes, ncol = total_cells)
rownames(counts) <- paste0("Gene", 1:n_genes)
colnames(counts) <- paste0("Cell", 1:total_cells)

# Expand sample and domain IDs according to cells_per_group
sample_domain <- expand.grid(
    sample_id = paste0("S", 1:n_samples),
    bayes_domain = paste0("Sp09D", sprintf("%02d", 1:n_domains))
)

sample_ids <- rep(sample_domain$sample_id, times = cells_per_group)
bayes_domains <- rep(sample_domain$bayes_domain, times = cells_per_group)

# Add someMetadata
col_data <- DataFrame(
    sample_id = sample_ids,
    BayesSpace_harmony_k09 = bayes_domains,
    diagnosis = sample(c("Control", "Case"), total_cells, replace = TRUE),
    age = sample(50:70, total_cells, replace = TRUE),
    pmi = runif(total_cells, 5, 20)
)

# Create demo SingleCellExperiment object
spe <- SingleCellExperiment(
    assays = list(counts = counts),
    colData = col_data
)

# Aggregate
summed_k <- aggregateAcrossCells(
    spe,
    DataFrame(
        BayesSpace = spe$BayesSpace_harmony_k09,
        reg_sample_id = spe$sample_id
    )
)

# Check ncells and rename to n_spots for spatialExperiment object
summed_k$nspots <- summed_k$ncells
print(summed_k$nspots)

# Filter small groups
min_nspots <- 2 # recommended min_nspots = 10
summed_k <- summed_k[, summed_k$nspots >= min_nspots]

# Convert variables
summed_k$diagnosis <- factor(summed_k$diagnosis, levels=c("Control", "Case"))
summed_k$age <- as.numeric(summed_k$age)
summed_k$pmi <- as.numeric(summed_k$pmi)
summed_k$BayesSpace <- as.factor(summed_k$BayesSpace)

# Run DE analysis
## Function to perform pseudoBulkDGE and return results
run_pseudoBulkDGE <- function(data, design, coef, method) {
    de_results <- pseudoBulkDGE(
        data,
        label = data$BayesSpace,
        design = design,
        coef = coef,
        condition = data$diagnosis,
        row.data = rowData(data),
        method = method
    )
}

## demo to use this function
# de_results_1 <- run_pseudoBulkDGE(summed_k, ~ diagnosis + age + nspots + pmi, "diagnosisCase", "edgeR")



