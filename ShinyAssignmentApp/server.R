#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(highcharter)
library(tidyverse)
library(DT)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

# Initial Investment
    
    output$initial <- renderText({input$initial})
    
# Interest Rate
    
    output$interest_rate <- renderText({input$interest_rate})
    
# Monthly Deposit Amount
    
    output$monthly_deposit <- renderText({input$monthly_deposit})
    
# Calculations
    
    investment <- eventReactive (input$calculate_button,{
        req(input$initial)
        req(input$years)
        req(input$interest_rate)
        req(input$monthly_deposit)
        
        ia <-input$initial
        ir <- (input$interest_rate)/100  
        t <- input$years
        n <- 12
        md <- input$monthly_deposit
        
        year_amount <- c()
        for (y in 1:t){
            add_amount <- ia*((1+ir/n)^(n*y)) + md *((((1 + ir/n)^(n*y))- 1)/(ir/n))
            year_amount <- append(year_amount, add_amount) 
        }
        year_amount <- round(year_amount, 2)
        year_amount <- c(ia, year_amount)
        
        deposit <- rep(n * md, t)
        deposit <- c(ia, deposit)
        
        year_vector <- 0:t
        
        compound_data <- cbind(year_vector, deposit, year_amount)
        compound_data <- as.data.frame(compound_data)
        
        compound_data$deposits_sum <- cumsum(compound_data$deposit)
        compound_data <- compound_data %>% 
            mutate(interest_sum=year_amount-deposits_sum)
        compound_data$interest_sum <- round(compound_data$interest_sum, 2)
        
        compound_data$interest <- compound_data$interest_sum - lag(compound_data$interest_sum)
        compound_data$interest <- compound_data$interest %>% replace_na(0)
        compound_data$interest <- round(compound_data$interest, 2)
        
        compound_data <- compound_data %>% select(year_vector, 
                                                  deposit, 
                                                  interest, 
                                                  deposits_sum, 
                                                  interest_sum, 
                                                  year_amount)
        
        names(compound_data) <- c("Year", 
                                  "Deposits", 
                                  "Interest", 
                                  "Total Deposits", 
                                  "Total Interest", 
                                  "Amount")
        
        number_rows <- t+1
        
        list(compound_data=compound_data, number_rows=number_rows)
        
        
    })
    
    ## Plot
    
    output$plot <-renderHighchart({ 
        
        highchart() %>% 
            hc_chart(type = "column") %>% 
            hc_xAxis(title = list(text = "Years")) %>% 
            hc_plotOptions(column = list(
                dataLabels = list(enabled = FALSE),
                stacking = "normal",
                enableMouseTracking = TRUE)
            ) %>% 
            hc_series( list(name="Total Interest",
                            data=investment()[['compound_data']]$`Total Interest`, 
                            color="#2ECC71"),
                       list(name="Total Deposits",
                            data=investment()[['compound_data']]$`Total Deposits`, 
                            color="#3498DB")
            )
    })
    
    ## Table
    
    output$compound_data_table <-DT::renderDataTable(server = TRUE,
                                                   (DT::datatable(
                            investment()[['compound_data']], 
                            rownames = FALSE,
                            options = list(scrollY = '450px', 
                                           pageLength = investment()[['number_rows']],
                                           dom = 't', 
                                           ordering=F) )
                            %>%formatRound(c("Deposits", 
                                             "Interest", 
                                             "Total Deposits", 
                                             "Total Interest", 
                                             "Amount"), 
                                           digits = 2)   ) )
})
