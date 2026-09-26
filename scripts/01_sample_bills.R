# =============================================================================
# scripts/01_sample_bills.R
# Build the application sample from the Comparative Agendas Project (CAP)
# Congressional Bills dataset (data/source/congressional_bills_19.3.csv,
# downloaded from comparativeagendas.net, see data/README.md).
#   - Congresses 111-114 (2009-2016; CAP v19.3 ends with the 114th); fields: bill id, congress, title, CAP major topic
#     (the 20 CAP major topics 1-10, 12-21; code 99 'other' excluded)
#   - stratified sample, seed 2026: 240 bills with major topic 3 (Health) and
#     560 from all other topics, proportional to their frequency
#   - health = 1 if major topic 3; split: validation = 200 drawn at random
#     (seed 2027), working = 600
# Output: data/bills_sample.csv (bill_id, congress, title, cap_majtopic, health, split)
# Run from the project root:  Rscript scripts/01_sample_bills.R
# =============================================================================
src <- "data/source/congressional_bills_19.3.csv"
stopifnot(file.exists(src))
raw <- read.csv(src, stringsAsFactors = FALSE, na.strings = c("NULL", "", "NA"))
cat(sprintf("[sample] source rows: %d\n", nrow(raw)))

b <- raw[raw$cong >= 111 & raw$cong <= 116, c("bill_id", "cong", "description", "majortopic")]
names(b) <- c("bill_id", "congress", "title", "cap_majtopic")
CAP_TOPICS <- c(1:10, 12:21)                   # the 20 CAP major topics (99 = other/none excluded)
b <- b[!is.na(b$cap_majtopic) & b$cap_majtopic %in% CAP_TOPICS & !is.na(b$title) & nzchar(trimws(b$title)) & !duplicated(b$bill_id), ]
b$title <- trimws(gsub("\\s+", " ", b$title))
b <- b[order(b$bill_id), ]                     # deterministic order before sampling
cat(sprintf("[sample] Congresses 111-114 with title and topic: %d bills; Health (3): %d (%.1f%%)\n",
            nrow(b), sum(b$cap_majtopic == 3), 100 * mean(b$cap_majtopic == 3)))

N_HEALTH <- 240; N_OTHER <- 560
set.seed(2026)
health_idx <- sample(which(b$cap_majtopic == 3), N_HEALTH)
other <- b[b$cap_majtopic != 3, ]
# proportional allocation across the other topics (largest-remainder rounding)
tab <- table(other$cap_majtopic)
alloc <- floor(N_OTHER * tab / sum(tab))
rem <- N_OTHER - sum(alloc)
frac <- N_OTHER * tab / sum(tab) - alloc
alloc[order(frac, decreasing = TRUE)[seq_len(rem)]] <- alloc[order(frac, decreasing = TRUE)[seq_len(rem)]] + 1
stopifnot(sum(alloc) == N_OTHER)
other_idx <- unlist(lapply(names(alloc), function(k) {
  pool <- which(b$cap_majtopic != 3 & b$cap_majtopic == as.integer(k))
  if (alloc[[k]] == 0) integer(0) else sample(pool, alloc[[k]])
}))
smp <- b[c(health_idx, other_idx), ]
smp$health <- as.integer(smp$cap_majtopic == 3)
stopifnot(nrow(smp) == 800, sum(smp$health) == 240)

set.seed(2027)
val <- sample(seq_len(nrow(smp)), 200)
smp$split <- "working"; smp$split[val] <- "validation"
smp <- smp[order(smp$split, smp$bill_id), c("bill_id", "congress", "title", "cap_majtopic", "health", "split")]
dir.create("data", showWarnings = FALSE)
write.csv(smp, "data/bills_sample.csv", row.names = FALSE)
cat(sprintf("[sample] written data/bills_sample.csv: %d rows; validation %d (health %d), working %d (health %d)\n",
            nrow(smp), sum(smp$split == "validation"), sum(smp$health[smp$split == "validation"]),
            sum(smp$split == "working"), sum(smp$health[smp$split == "working"])))
print(table(topic = smp$cap_majtopic))
cat(sprintf("[sample] title length: median %d words (range %d-%d)\n",
            median(lengths(strsplit(smp$title, " "))), min(lengths(strsplit(smp$title, " "))), max(lengths(strsplit(smp$title, " ")))))
