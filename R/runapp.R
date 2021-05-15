

#' @export
app <- function() {
  appdir <- system.file("shiny", "edibbleGUI", package = "edibbleGUI")
  shiny::runApp(appdir)
}
