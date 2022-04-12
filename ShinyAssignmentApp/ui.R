
# Compound Interest Calculator


# Libraries
library(shiny)
library(highcharter)
library(tidyverse)
library(DT)

# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel(HTML(paste0(strong("Compound Interest Calculator")))),

    # Sidebar with a slider input information
    sidebarLayout(
        sidebarPanel(
            numericInput("initial",
                         "Initial Investment:",
                         min = 0,
                         step = 100,
                        value = 5000),
            numericInput("interest_rate",
                         "Interest Rate %:",
                         min = 0,
                         step = 0.1,
                         value = 5),
            sliderInput("years",
                        "Select the Number of Years:",
                        min = 0,
                        max = 100,
                        value = 20),
            numericInput("monthly_deposit",
                         "Monthly Deposit Amount:",
                         step = 100,
                         value = 100),
            actionButton("calculate_button",
                         "Calculate",
                         icon("calculator")
                        ),
            helpText(HTML(paste0(strong("All fields are required."))))
            
        ),

        # Show a plot and data table
        mainPanel(
            highchartOutput("plot"),
            
            #textOutput("initial_amount_text")
           
            DT::dataTableOutput("compound_data_table")
        )
    )
)
)
