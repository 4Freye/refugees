setwd("/Users/ericfrey/Documents/thesis/")

# Load migration data
data <- read.csv("data.csv")
data = data[!duplicated(data[c('Country_o', 'Country_d', 'year')]),]

map_to_region <- function(country_column) {
  africa = c('The Gambia','Côte d\'Ivoire', 'Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cameroon', 'Central African Republic', 'Chad', 'Comoros', 'Democratic Republic of the Congo', 'Djibouti', 'Egypt', 'Equatorial Guinea', 'Eritrea', 'Eswatini', 'Ethiopia', 'Gabon', 'Ghana', 'Guinea', 'Guinea-Bissau', 'Kenya', 'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius', 'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Republic of Congo', 'Rwanda', 'Sao Tome and Principe', 'Senegal', 'Seychelles', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan', 'Tanzania', 'Togo', 'Tunisia', 'Uganda', 'Zambia', 'Zimbabwe')

  north_america = c('Canada', 'Mexico', 'United States', 'The Bahamas', 'Puerto Rico')
  
  former_soviet_union = c('Armenia', 'Azerbaijan', 'Belarus', 'Estonia', 'Georgia', 'Kazakhstan', 'Kyrgyz Republic', 'Latvia', 'Lithuania', 'Moldova', 'Russia', 'Tajikistan', 'Turkmenistan', 'Ukraine', 'Uzbekistan')
  
  south_asia = c('Afghanistan', 'Bangladesh', 'Bhutan', 'India', 'Iran', 'Maldives', 'Nepal', 'Pakistan', 'Sri Lanka')
  
  west_asia = c('Bahrain', 'Cyprus', 'Iraq', 'Israel', 'Jordan', 'Kuwait', 'Lebanon', 'Oman', 'Qatar', 'Saudi Arabia', 'Syria', 'United Arab Emirates', 'Yemen', 'Islamic Republic of Iran', 'Türkiye', 'West Bank and Gaza')
  
  southeast_asia = c('Brunei Darussalam', 'Cambodia', 'Indonesia', 'Lao PDR', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Timor-Leste', 'Vietnam', 'Lao P.D.R.')
  
  oceania = c('Australia', 'Fiji', 'Kiribati', 'Marshall Islands', 'Micronesia', 'Nauru', 'New Zealand', 'Palau', 'Papua New Guinea', 'Samoa', 'Solomon Islands', 'Tonga', 'Tuvalu', 'Vanuatu')
  
  latin_america = c('St. Lucia', 'St. Vincent and the Grenadines', 'St. Kitts and Nevis', 'São Tomé and Príncipe', 'Aruba', 'Antigua and Barbuda', 'Argentina', 'Barbados', 'Belize', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Costa Rica', 'Cuba', 'Dominica', 'Dominican Republic', 'Ecuador', 'El Salvador', 'Grenada', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaica', 'Nicaragua', 'Panama', 'Paraguay', 'Peru', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Suriname', 'Trinidad and Tobago', 'Uruguay', 'Venezuela')
  europe = c('Albania', 'Andorra', 'Austria', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria', 'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Ireland', 'Italy', 'Kazakhstan', 'Kosovo', 'Latvia', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland', 'Portugal', 'Romania', 'Russia', 'San Marino', 'Serbia', 'Slovak Republic', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom', 'Uzbekistan')
  east_asia = c('China','Hong Kong SAR','Japan','Korea', 'Macao SAR', 'Mongolia', 'Taiwan Province of China')

  region_column <- vector('character', length(country_column))
  for (i in seq_along(country_column)) {
    if (country_column[i] %in% africa) {
      region_column[i] <- 'Africa'
    } else if (country_column[i] %in% north_america) {
      region_column[i] <- 'North America'
    } else if (country_column[i] %in% former_soviet_union) {
      region_column[i] <- 'Fmr Soviet Union'
    } else if (country_column[i] %in% south_asia) {
      region_column[i] <- 'South Asia'
    } else if (country_column[i] %in% west_asia) {
      region_column[i] <- 'West Asia'
    } else if (country_column[i] %in% southeast_asia) {
      region_column[i] <- 'Southeast Asia'
    } else if (country_column[i] %in% oceania) {
      region_column[i] <- 'Oceania'
    } else if (country_column[i] %in% latin_america) {
      region_column[i] <- 'Latin America'
    } else if (country_column[i] %in% europe) {
      region_column[i] <- 'Europe'
    } else if (country_column[i] %in% east_asia) {
      region_column[i] <- 'East Asia'
    } else {
      region_column[i] <- NA_character_
    }
  }
  return(region_column)
}

data$Region_o <- map_to_region(data$Country_o)
data$Region_d <- map_to_region(data$Country_d)

library(dplyr)
library(tidyr)
library(migest)
library(ggplot2)
library(gganimate)

library(ggplot2)
library(ggchicklet)
library(magick)

#set up data for this visualization
data_summary <- data %>%
  group_by(Region_o, Region_d, year) %>%
  summarise(newarrival = sum(newarrival)) %>%
  select(Region_o, Region_d, newarrival, year) %>%
  rename(orig = Region_o, dest = Region_d, flow = newarrival) %>%
  ungroup() %>% 
  as.data.frame() %>% 
  mutate(flow = flow/1000)

mig_chord(data_summary %>% filter(year==2020))


# Set the range of years you want to include
years <- 2000:2021

# Loop over the years and create a plot for each year
for (one_year in years) {
  data_year <- data_summary %>%
    filter(year == one_year)
  
  png(file = paste0("chord", one_year, ".png"))
  mig_chord(data_year, title=one_year)
  # plots[[yr-1999]] <- image_write("plot.png", format = "png")
  dev.off()
  # file.show("chord.png")
}

# List all the PNG files in the current directory that start with "chord"
png_files <- list.files(pattern = "^chord.*\\.png$")

# Read in each PNG file as a magick image
images <- magick::image_read(png_files)

images <- image_annotate(images,as.character(2000:2021), size = 15, font='arial')


# loop through each frame of the GIF and write it to a separate PNG file
for (i in seq_along(images)) {
  image_write(images[i], path = sprintf("/Users/ericfrey/Documents/thesis/chord%02d.png", i), format = "png")
}

# Combine the images into an animated GIF
gif <- magick::image_animate(images, delay=200)

# Write the GIF to a file
magick::image_write(gif, "migration_slower.gif")


# interactive map
library(ggplot2)
library(leaflet)
library(dplyr)
library(sp)
library(countrycode)

library(data.table)
library(ggplot2)

# Load the world map data
world_map <- map_data("world")

# Convert to a data.table and set key columns
world_map_dt <- setDT(world_map, key = c("region", "order"))

data <- setDT(data, key=c('Country_o','Country_d','year'))

# Merge with world map data
merged_data <- merge(world_map_dt, data[data$year==2010  & data$newarrival > 100][, sum(newarrival), by=Country_o], by.x = "region", by.y = "Country_o", all.x = TRUE, allow.cartesian=TRUE)

# Create a base map centered on the US
leaflet() %>% setView(lng = -6, lat = 41.574886, zoom = 2) %>% 
  # Add a tile layer from Mapbox
  addTiles() %>%
  addPolygons(fillColor = ~colorQuantile("YlOrRd", pop)(pop),
              fillOpacity = 0.7, color = "#BDBDC3",
              weight = 1)

library(maps)
mapCountries = map("world", fill = TRUE, plot = FALSE)
leaflet(data = mapCountries) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(5, alpha = NULL), stroke = FALSE)

trends_strings = c('asesores+asesores', 'agente', 'extraterrestres', 'solicitante+solicitantes+solicitud+aplicar', 'cita', 'llegada+llegadas', 'asimilar+asimilación', 'asilo', 'solicitante de asilo', 'austeridad', 'rescate', 'beneficio+beneficios', 'bilateral', 'biométrico', 'nacimientos', 'controles fronterizos+control de fronteras', 'oficina de inmigración', 'negocio+negocios', 'tarjeta', 'certificado', 'controlar', 'control+puntos de control', 'ciudadano', 'ciudadanía+ciudadanías', 'compensación+compensaciones', 'competitividad', 'consulado+consulados', 'contrato+contratos', 'cooperación', 'crisis+crisis', 'acortar', 'aduanas', 'cíclico', 'descentralización+descentralización', 'disminuido', 'déficits', 'democratización+democratización', 'demográfico+demografía', 'departamento', 'deportación+deportaciones+deportado', 'desregulación', 'detener+detenido+detención', 'determinantes', 'devaluación', 'diáspora', 'discriminar+discriminatorio', 'disparidades', 'diversificación', 'diversidad', 'documentos', 'recesión', 'la doble nacionalidad', 'doble nacionalidad', 'ganador+ganancias', 'económicamente', 'economista+economistas', 'economía+economías', 'élites', 'embajada+embajadas', 'emigrante+emigrantes', 'emigrar+emigró', 'emigración', 'empleador+empleadores', 'empleo', 'empoderamiento', 'aplicación+hace cumplir', 'exclusión', 'exportaciones', 'extensión', 'extranjero+extranjeros', 'forma', 'pib', 'geopolítico', 'globalización+globalización', 'crecimiento', 'hora.+hora', 'privación+dificultades', 'contratación', 'patria', 'postergación', 'ilegal+ilegalmente', 'inmigrante+inmigrantes', 'inmigrar+inmigró', 'inmigración', 'incentivos', 'ingreso+ingresos', 'contratado', 'indicadores', 'individualismo', 'industrialización+industrialización', 'industrializado+industrializado', 'ineficacia', 'desigualdades+desigualdad', 'inflación', 'afluencia', 'inestabilidad', 'seguro', 'matrimonio mixto', 'pasantía+pasantías', 'entrevista', 'trabajo+trabajos', 'mano de obra+mano de obra+obreros+obreros', 'suspender+despidos', 'legalización+legalización+legalizaciones+legalizaciones', 'liberalización+liberalización', 'lotería', 'macro+macroeconómico', 'casamiento', 'inmigrante+migrantes', 'emigrar', 'migración', 'mínimo', 'mala administración', 'monetario', 'monopolios', 'multicultural+multiculturalismo', 'nacionalidad+nacionalidades', 'nacionalización+nacionalización', 'naturalización+naturalización+naturalizaciones+naturalizaciones', 'noticias', 'pasaporte+pasaportes', 'nómina de sueldos+nóminas', 'pensión+pensiones', 'permiso', 'pogromos', 'políticas', 'responsables políticos', 'asilo político', 'refugiado político', 'poblar', 'privatización+privatización', 'productividad', 'prosperidad', 'cuarentena', 'cuota+cuotas', 'recesión+recesiones', 'reclutamiento+contrataciones', 'reformas', 'refugiado+refugiados', 'remuneración+remuneraciones', 'renovación', 'repatriación', 'documentos requeridos+documento requerido', 'requisitos', 'restablecimiento', 'restringir+restringiendo', 'restricción', 'restrictivo', 'reunificación', 'revitalización+revitalización', 'salario+sueldos', 'sanciones', 'schengen', 'sectores', 'buscadores', 'depresión', 'contrabandista+contrabandistas+contrabando', 'seguridad social', 'patrocinador', 'esposos', 'estabilización+estabilización', 'estancamiento', 'apátrida', 'estado', 'estímulo', 'visa de estudiante', 'suficiencia', 'aranceles', 'impuesto+impuestos', 'prueba', 'apretado+apretando', 'turista+turistas', 'traficado+tráfico', 'no autorizado+no autorizado', 'subdesarrollado', 'indocumentado', 'desempleo', 'unión+sindicatos', 'no capacitado', 'insostenible', 'vacante+vacantes', 'viabilidad', 'sin visa', 'visa+visas', 'salario+salarios', 'exención+renuncias', 'bienestar', 'bienestar', 'aflicciones', 'visa de trabajo', 'obrero', 'empeoramiento')


gtrendsR::gtrends(keyword="Cúcuta", geo=  "VE", time="2018-01-01 2019-01-01", low_search_volume = TRUE, compared_breakdown = FALSE, )$interest_over_time

