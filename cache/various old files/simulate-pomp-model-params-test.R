# simulate-pomp-model.R
#
# This script runs the previously generated pomp model
# it does not do fitting, but can be used for exploration 
# and to generate generate synthetic data

rm(list = ls(all.names = TRUE))

# Load libraries ----------------------------------------------------------
library(pomp)
library(dplyr)
library(tidyr)
library(ggplot2)
library(here) #to simplify loading/saving into different folders

# Load pomp simulator object ---------------------------------------------------------
filename = here('output/pomp-model.RDS')
pomp_model <- readRDS(filename)


#load values for model parameters and initial conditions
filename = here('output/var-par-definitions.RDS')
allparvals <- readRDS(filename)$allparvals

# allparvals <- coef(readRDS(here("output/2020-04-09-forecasts/pmcmc-output.RDS"))) %>%
#   as.data.frame() %>%
#   t() %>%
#   colMeans()

# M2 <- pomp_model
# horizon <- 7*6
# time(M2) <- c(time(pomp_model), max(time(pomp_model))+seq_len(horizon))
# out <- tibble()
# for(i in 1:6){
#   allparvals <- coef(readRDS(here("output/mif-results.RDS"))[[1]][[i]])
#   sims <- pomp::simulate(M2, 
#                          params=allparvals, 
#                          nsim=1, format="data.frame", 
#                          include.data=FALSE)
#   
#   # filename = here('output/model-predictions.RDS')
#   # saveRDS(sims,filename)
#   start_date <- as.Date("2020-03-01")
#   end_date <- start_date + max(sims$time) - 1
#   dates <- seq.Date(start_date, end_date, "days") 
#   dates_df <- data.frame(time = c(1:length(dates)), Date = dates)
#   
#   pl <- sims %>%
#     left_join(dates_df) %>%
#     dplyr::select(Date, .id, C_new, H_new, D_new) %>%
#     mutate(mif = i)
#   out <- bind_rows(out, pl)
# }
# 
# out %>%
#   gather(key = "State", value = "value", -Date, -.id, -mif) %>%
#   ggplot(aes(x = Date, y = value, color = as.factor(mif), group = paste0(mif,.id))) +
#   geom_line() +
#   facet_wrap(~State, scales = "free") +
#   ggtitle("t_int = 12")


# allparvals <- coef(readRDS(here("output/mif-results.RDS"))[[1]][[5]])
M2 <- pomp_model
horizon <- 7*20
time(M2) <- c(time(pomp_model), max(time(pomp_model))+seq_len(horizon))
#run simulation a number of times
# allparvals["beta_reduce"] <- 1
# allparvals["log_beta_s"] <- -17.1
# allparvals["t_int1"] <- 35
sims <- pomp::simulate(pomp_model, 
                       params=allparvals, 
                       nsim=10, format="data.frame", 
                       include.data=TRUE)

# filename = here('output/model-predictions.RDS')
# saveRDS(sims,filename)
start_date <- as.Date("2020-03-01")
end_date <- start_date + max(sims$time) - 1
dates <- seq.Date(start_date, end_date, "days") 
dates_df <- data.frame(time = c(1:length(dates)), Date = dates)

pl <- sims %>%
  left_join(dates_df) %>%
  # dplyr::select(Date, .id, C_new, H_new, D_new) %>%
  dplyr::select(Date, .id, cases, hosps, deaths) %>%
  tidyr::gather(key = "variable", value = "value", -Date, -.id) %>%
  ggplot(aes(x = Date, y = value, group = .id, color=.id=="data")) +
  geom_line() +
  facet_wrap(~variable, scales = "free_y") +
  guides(color = FALSE) 

plot(pl)


# Plot H1 and hosps

# sims %>%
#   dplyr::select(time, .id, hosps, H1) %>%
#   filter(.id != "data") %>%
#   tidyr::gather(key = "variable", value = "value", -time, -.id) %>%
#   group_by(time, variable) %>%
#   summarise(MeanLine = mean(value)) -> meantraj
# 
# sims %>%
#   dplyr::select(time, .id, hosps, H1) %>%
#   filter(.id != "data") %>%
#   tidyr::gather(key = "variable", value = "value", -time, -.id) -> thesims
# 
# ggplot() +
#   geom_line(data = thesims, aes(x = time, y = value, group = .id), alpha = 0.05) +
#   geom_line(data = meantraj, aes(x = time, y = MeanLine), size = 1, color = "red") +
#   facet_wrap(~variable) +
#   guides(color = FALSE)





  
