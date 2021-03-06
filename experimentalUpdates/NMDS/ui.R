#Lj1eob9ngJDqu
#runApp('./NMDS', launch.browser = FALSE)

library(shiny)
library(vegan)
library(RColorBrewer)
data(dune)
data("dune.env")

## ui.R

shinyUI(
  pageWithSidebar(
    
    # Header defintion
    headerPanel("Perform a non-metric multidimensional scaling analysis..."),
    
    # Sidebar defintion
    sidebarPanel(
      tabsetPanel(
        tabPanel("Data upload", 
                 h5("Description"),
                 p("This App will perform an NMDS analysis using the metaMDS() function from the vegan package for R. Dissimilarities are calculated by vegdist() {vegan} and transformations are performed by decostand() {vegan}."),
                 
                 h5("Example data"),
                 p("Tick the box below if you'd like to use the 'dune' dataset included in the vegan package as an example."),
                 checkboxInput('useExampleData', 'Use an example dataset', FALSE),
                 
                 h5("CSV parameters"),
                 p("Note that these parameters apply to all files uploaded. If your files are not correctly formatted, errors will result."),
                 
                 
                 # Parameters for read.csv...
                 checkboxInput('header', 'Header', TRUE),
                 
                 numericInput(
                   inputId = 'rownames',
                   value = 1,
                   min = 0,
                   label = 'Which column contains row lables (enter "0" if there is no such column)?'
                 ),
                 
                 radioButtons(
                   inputId = 'sep',
                   label = 'Separator',
                   choices = c(
                     Comma = ',',
                     Semicolon = ';',
                     Tab = '\t'
                   )
                 ),
                 
                 radioButtons(
                   inputId = 'quote',
                   label = 'Quote',
                   choices = c(
                     'Double quotes' = '"',
                     'Single quotes' = "'",
                     'None' = ''
                   )
                 ),
                 
                 fileInput(
                   inputId = 'dataset', 
                   label = 'Select a CSV file to upload for analysis...',
                   accept = c('text/csv','text/comma-separated-values','.csv')
                 )
                 
                 
                 
        ),
        
        tabPanel(
          "Transformations",
          strong("Note, most of these transformations are only valid for numeric variables. Attempting these transformation on non-numeric variables will lead to errors."),		
          br(),
          br(),
          # Should the data be transformed? Input for decostand()
          
          radioButtons(
            inputId = 'transform',
            label = 'If needed, select a transformation for your response data...',
            choices = c(
              'No transformation' = 'none',
              'Z score' = 'standardize',
              'Chi square' = 'chi.square',
              'Hellinger' = 'hellinger'
            )
          )
        ),
        
        tabPanel(
          "NMDS parameters",
          # Parameters for metaMDS...
          # Select dissimilarity measure
          radioButtons(
            inputId = 'dissim',
            label = 'Select a dissimilarity measure. Note, the Jaccard measure is only valid for presence absence data.',
            choices = c(
              'Euclidean' = 'euclidean',
              'Bray-Curtis' = 'bray',
              'Jaccard (presence/absence data)' = 'jaccard' # This will set presAbs to TRUE
            )
          ),
          
          # Presence absence or abundance?
          radioButtons(
            inputId = 'presAbs',
            label = 'Do you have abundance (or other count data) or presence/absence data?',
            choices = c(
              # Logicals fed into 'binary = ' arg of vegdist()
              'Abundance' = 'FALSE', 
              'Presence / Absence' = 'TRUE'
            )
          ),
          
          # Number of dimensions to allow.
          # In addition to changing the parameters of metaMDS(), this option
          # will trigger either a single plot (dimNum = 2) or a multi-
          # panel plot (dimNum = 3) as graphical output.
          radioButtons(
            inputId = 'dimNum',
            label = 'How many dimensions should the solution have?',
            choices = c(
              'Two' = 2,
              'Three' = 3
            )
          ),
          
          
          
          h5("Graphical parameters"),
          # Label points?
          checkboxInput('labels', 'Label points?', FALSE),
          
          #introduce an option where files containing coloring factors can be uploaded
          fileInput(inputId = "colorfile", 
                    label = "Upload the file with the factors according to which NMDS results will be colored. Please make sure the file is in the csv format.",
                    accept = c("text/csv", "text/comma-separated-values", ".csv")),
          
          checkboxInput('header2', 'Header', TRUE),
          
          numericInput(
            inputId = 'rownames2',
            value = 0,
            min = 0,
            label = 'Which column contains row lables from the color- data file (enter "0" if there is no such column)?'
          ),
          
          radioButtons(inputId = "factorType", 
                       label = "Please specify if the chosen variable is numeric or a factor", 
                       choices = c("Numeric", "Factor"), 
                       selected = NULL),
          
          checkboxInput('useExampleDataColor', 'Use an example dataset as coloring variables', FALSE),
          htmlOutput("colorVariable"),
          
          checkboxInput('showPoint', 
                        'Visualize the colored datapoints', 
                        TRUE),
          
          h5("Select the graph type for your NMDS outcome"),
          checkboxInput('Spider', "Spider", FALSE),
          checkboxInput('Hull', "Hull", FALSE),
          checkboxInput('Ellipse', "Ellipse", FALSE),
           
          #introduce an option where files containing sizing factors can be uploaded
          fileInput(inputId = "sizefile", 
                    label = "Upload the file with the numeric factors according to which NMDS results will be scaled. Please make sure the file is in the csv format.",
                    accept = c("text/csv", "text/comma-separated-values", ".csv")),
          
          checkboxInput('header3', 'Header', TRUE),
          
          numericInput(
            inputId = 'rownames3',
            value = 0,
            min = 0,
            label = 'Which column contains row lables from the size- data file (enter "0" if there is no such column)?'
          ),
          
          checkboxInput('useExampleDataSize', 'Use an example dataset as sizing variables', FALSE),
          htmlOutput("scalingVariable")
          
        ),
        
        # Download panel
        tabPanel(
          "Download results...",
          downloadButton('downloadData.dissMat', 'DOWNLOAD dissimilarity matrix...'),
          br(),
          downloadButton('downloadData.plot', 'Download ordination...'),
          br(),
          downloadButton('downloadData.stressplot', 'Download stress plot...'),
          br(),
          downloadButton('downloadData.objectCoordinates', 'Download object coordinates...')			
        )
      ) # End tabSetPanel()
    ), # End sideBarPanel()
    
    # Main panel defintion
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot")),
        tabPanel("Shepard stress plot", plotOutput("stressplot")),
        tabPanel("Summary", verbatimTextOutput("print")),
        tabPanel("Object coordinates", tableOutput("objectCoordinates"))
      )
    ) # End mainPanel()
    
  ) # End pageWithSidebar()
) # End shinyUI()

