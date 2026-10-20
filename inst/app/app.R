# rallyr browser app: upload past sessions, add the latest, download, see charts.
#
# Everything runs in the browser (Shinylive / WebAssembly R). Files you pick
# are read locally and never uploaded; the app makes no requests to other
# sites. See the "About and privacy" tab.
#
# Two ways to run it:
#  * in the browser: the build (tools/build_app.R) copies the package code the
#    app needs into pkg_R/ and the sample bundle into data/, and Shinylive
#    exports the folder;
#  * in R, for development: shiny::runApp(system.file("app", package = "rallyr"))
#    uses the installed package instead.

# Only the UI packages are attached. The others (dplyr, jsonlite, cli, tibble,
# rlang) are used through `pkg::name`, so their functions cannot mask shiny's
# (attaching jsonlite, for one, replaces shiny::validate()).
library(shiny)
library(bslib)
library(ggplot2)

`%||%` <- function(a, b) if (is.null(a)) b else a

app_dir <- shiny::getShinyOption("appDir", default = getwd())
bundled_sources <- file.path(app_dir, "pkg_R", "rallyr_app_sources.R")
if (file.exists(bundled_sources)) {
  .data <- rlang::.data
  source(bundled_sources, local = globalenv())
  api_base <- function() sv_api_base()
} else {
  library(rallyr)
  api_base <- function() getFromNamespace("sv_api_base", "rallyr")()
}

sample_path <- local({
  bundled <- file.path(app_dir, "data", "synthetic_sample_bundle.json.gz")
  if (file.exists(bundled)) bundled else system.file("extdata", "synthetic_sample_bundle.json.gz", package = "rallyr")
})
sample_bundle <- bundle_read(sample_path)
sample_player <- "Sample Player"

token_ok <- function(x) nzchar(x) && grepl("^[A-Za-z0-9._~-]+$", x)

# Message text of an error, without formatting.
plain_error <- function(e) gsub("\\s+", " ", cli::ansi_strip(conditionMessage(e)))

# Detect the kind of each dropped file (by content); NA when not recognised.
detect_kinds <- function(paths) {
  vapply(paths, function(p) {
    tryCatch(bundle_payload_kind(p, strict = FALSE), error = function(e) NA_character_)
  }, character(1), USE.NAMES = FALSE)
}

two_col <- function(metric, value) tibble::tibble(Metric = metric, Value = as.character(value))

# The server sends 'rallyr_tick'; the browser answers on its next turn, which
# lets the page repaint between two sessions' worth of computing.
tick_script <- "
(function register() {
  if (window.Shiny && Shiny.addCustomMessageHandler) {
    Shiny.addCustomMessageHandler('rallyr_tick', function(m) {
      setTimeout(function() { Shiny.setInputValue('tick', Math.random(), {priority: 'event'}); }, 0);
    });
  } else {
    setTimeout(register, 25);
  }
})();"

dark_toggle <- if ("input_dark_mode" %in% getNamespaceExports("bslib")) bslib::input_dark_mode() else NULL

ui <- bslib::page_sidebar(
  title = "rallyr: your sessions, in your browser",
  theme = bslib::bs_theme(version = 5),
  fillable = FALSE,
  tags$head(tags$script(HTML(tick_script))),
  sidebar = bslib::sidebar(
    width = 360, open = "always",
    dark_toggle,
    tags$p(class = "small text-body-secondary", "Your files stay in this browser tab. Nothing is uploaded."),
    tags$h6("1. Your past sessions"),
    fileInput("bundle_file", NULL, accept = c(".gz", ".json"), buttonLabel = "Choose bundle",
              placeholder = "bundle .json.gz (optional)"),
    actionLink("reset", "Show the synthetic sample again"),
    tags$hr(),
    tags$h6("2. Your latest session"),
    textInput("share_url", "Paste the share link", placeholder = "the link you were sent"),
    uiOutput("api_links"),
    fileInput("raw_files", "Drop the saved JSON files", multiple = TRUE, accept = ".json",
              buttonLabel = "Choose files", placeholder = "the match, stats and shots files"),
    tableOutput("raw_detect"),
    tags$hr(),
    tags$h6("3. Who you are"),
    selectizeInput("me", NULL, choices = c(sample_player), selected = sample_player,
                   options = list(create = TRUE, placeholder = "Your name as SwingVision shows it")),
    tags$hr(),
    tags$h6("4. Add and save"),
    actionButton("merge", "Add session to bundle", class = "btn-primary"),
    tags$div(class = "mt-2", downloadButton("download", "Download updated bundle"))
  ),
  uiOutput("status"),
  bslib::navset_card_tab(
    id = "tabs",
    bslib::nav_panel(
      "Charts",
      sliderInput("range", "Trend window (default: last 3 months)",
                  min = as.Date("2000-01-01"), max = as.Date("2000-01-02"),
                  value = c(as.Date("2000-01-01"), as.Date("2000-01-02")),
                  timeFormat = "%d %b %Y", width = "100%"),
      bslib::layout_columns(
        col_widths = c(12, 6, 6, 6, 6),
        bslib::card(bslib::card_header("Session trends"), plotOutput("plot_trend", height = "420px"),
                    tags$ul(class = "small", tags$li("One point per session."), tags$li("Slider limits this chart only."))),
        bslib::card(bslib::card_header("Rally length by drill"), plotOutput("plot_rally", height = "320px"),
                    tags$ul(class = "small", tags$li("Both players' shots per rally."), tags$li("After data-quality corrections."))),
        bslib::card(bslib::card_header("Stroke speed by drill"), plotOutput("plot_speed", height = "320px"),
                    tags$ul(class = "small", tags$li("Your strokes only."), tags$li("Placeholder speeds removed."))),
        bslib::card(bslib::card_header("Net clearance by drill"), plotOutput("plot_net", height = "320px"),
                    tags$ul(class = "small", tags$li("Median per session."), tags$li("Height reference is not stated by the vendor."))),
        bslib::card(bslib::card_header("Pauses between strokes"), plotOutput("plot_gap", height = "320px"),
                    tags$ul(class = "small", tags$li("Dashed lines: the pause that splits a rally.")))
      )
    ),
    bslib::nav_panel(
      "Summary",
      tableOutput("summary"),
      tags$h6("Sessions"),
      tableOutput("sessions")
    ),
    bslib::nav_panel(
      "Merge report",
      uiOutput("merge_msg"),
      tableOutput("merge_summary"),
      tableOutput("merge_table")
    ),
    bslib::nav_panel(
      "About and privacy",
      tags$ul(
        tags$li("This page runs R in your browser (WebAssembly). Files you choose are read here and are not uploaded."),
        tags$li("It makes no requests to other sites: no analytics, no proxy, no fonts or scripts from elsewhere."),
        tags$li("The only links that leave this page are the API links in step 2, and only if you click them."),
        tags$li("The vendor's server does not let a web page read those links directly, so you open each one, save the JSON, and drop the files here."),
        tags$li("A bundle holds your raw session data. Keep it private; closing this tab forgets everything."),
        tags$li("Merging: a session already in the bundle (same match id) is replaced by the newer copy."),
        tags$li("Charts start with a synthetic sample, not real data.")
      ),
      tags$p(class = "small", "Source and documentation: ",
             tags$a(href = "https://github.com/JohnGavin/rallyr", "github.com/JohnGavin/rallyr",
                    rel = "noopener noreferrer"))
    )
  )
)

server <- function(input, output, session) {
  bundle <- reactiveVal(sample_bundle)
  source_kind <- reactiveVal("sample")   # "sample" until the user supplies data
  merge_result <- reactiveVal(NULL)       # list(msg, report)
  cache <- new.env()
  prime <- reactiveValues(todo = integer(0), done = 0L, total = 0L, ready = FALSE, me = "")

  set_players <- function(b, keep = NULL) {
    players <- bundle_players(b)
    sel <- if (!is.null(keep) && nzchar(keep)) keep else ""
    updateSelectizeInput(session, "me", choices = unique(c(players, sel[nzchar(sel)])), selected = sel)
  }

  # ---- 1. past sessions ---------------------------------------------------
  observeEvent(input$bundle_file, {
    f <- input$bundle_file
    res <- tryCatch(bundle_read(f$datapath[1]), error = function(e) e)
    if (inherits(res, "error")) {
      showNotification(paste("Could not read that bundle:", plain_error(res)), type = "error", duration = NULL)
      return()
    }
    bundle(res)
    source_kind("user")
    merge_result(list(
      msg = sprintf("Loaded a bundle of %d session(s). Enter your name in step 3.", length(res$sessions)),
      report = NULL
    ))
    set_players(res)
    bslib::nav_select("tabs", "Merge report")
  })

  observeEvent(input$reset, {
    bundle(sample_bundle)
    source_kind("sample")
    merge_result(NULL)
    set_players(sample_bundle, keep = sample_player)
  })

  # ---- 2. latest session --------------------------------------------------
  output$api_links <- renderUI({
    url <- trimws(input$share_url %||% "")
    if (!nzchar(url)) return(NULL)
    tok <- sv_token(url)
    if (!token_ok(tok)) {
      return(tags$p(class = "text-danger small", "That does not look like a share link."))
    }
    base <- api_base()
    links <- c(
      "match" = sprintf("%s/matches/%s", base, tok),
      "stats" = sprintf("%s/matches/%s/stats", base, tok),
      "shots" = sprintf("%s/matches/%s/shots", base, tok)
    )
    tags$div(
      tags$p(class = "small", "Open each link, save the page as a .json file, then drop the three files below."),
      tags$ol(class = "small", lapply(names(links), function(k) {
        tags$li(tags$a(href = links[[k]], target = "_blank", rel = "noopener noreferrer", k))
      }))
    )
  })

  raw_info <- reactive({
    f <- input$raw_files
    req(f)
    kinds <- detect_kinds(f$datapath)
    tibble::tibble(File = f$name, Detected = ifelse(is.na(kinds), "not recognised", kinds), path = f$datapath)
  })
  output$raw_detect <- renderTable(raw_info()[, c("File", "Detected")], spacing = "xs")

  observeEvent(input$merge, {
    info <- raw_info()
    need <- c("match", "stats", "shots")
    counts <- table(factor(info$Detected, levels = need))
    if (any(counts != 1L) || sum(counts) != nrow(info)) {
      showNotification(
        "Drop exactly one match, one stats and one shots file (see the table). Add one session at a time.",
        type = "error", duration = 8
      )
      return()
    }
    base <- if (source_kind() == "sample") bundle_new() else bundle()
    tok <- trimws(input$share_url %||% "")
    token <- if (token_ok(sv_token(tok))) sv_token(tok) else NA_character_
    out <- tryCatch(
      bundle_add_raw(
        base, info$path[info$Detected == "match"], info$path[info$Detected == "stats"],
        info$path[info$Detected == "shots"], token = token
      ),
      error = function(e) e
    )
    if (inherits(out, "error")) {
      showNotification(paste("Could not add the session:", plain_error(out)), type = "error", duration = NULL)
      return()
    }
    rep <- attr(out, "merge_report")
    merge_result(list(
      msg = if (source_kind() == "sample") {
        "Started a new bundle: the synthetic sample is not mixed with your data."
      } else {
        "Session added."
      },
      report = rep
    ))
    bundle(out)
    source_kind("user")
    set_players(out, keep = trimws(input$me %||% ""))
    bslib::nav_select("tabs", "Merge report")
  })

  # ---- 4. download --------------------------------------------------------
  output$download <- downloadHandler(
    filename = function() sprintf("rallyr_bundle_%s.json.gz", format(Sys.Date(), "%Y%m%d")),
    content = function(file) bundle_write(bundle(), file),
    contentType = "application/gzip"
  )

  # ---- computing, one session per browser round trip ----------------------
  # Each step is one session; the browser answers between steps, so the page
  # stays responsive and the status line updates (a long loop would freeze it).
  me <- reactive(trimws(input$me %||% ""))

  observe({
    b <- bundle()
    m <- me()
    isolate({
      prime$ready <- FALSE
      prime$me <- m
      prime$done <- 0L
      prime$todo <- if (nzchar(m)) seq_along(b$sessions) else integer(0)
      prime$total <- length(prime$todo)
    })
    if (nzchar(m)) session$sendCustomMessage("rallyr_tick", list())
  })

  observeEvent(input$tick, {
    todo <- prime$todo
    m <- prime$me
    if (length(todo) == 0L) {
      if (nzchar(m)) prime$ready <- TRUE
      return()
    }
    one <- bundle_new()
    one$sessions <- bundle()$sessions[todo[1]]
    bundle_to_tables(one, m, on_error = "skip", cache = cache)
    prime$todo <- todo[-1]
    prime$done <- prime$done + 1L
    session$sendCustomMessage("rallyr_tick", list())
  })

  tables <- reactive({
    validate(need(nzchar(me()), "Enter your player name in step 3 to draw the charts."))
    validate(need(prime$ready, "Reading sessions..."))
    bundle_to_tables(bundle(), me(), on_error = "skip", cache = cache)
  })

  derived <- reactive({
    t <- tables()
    validate(need(
      nrow(t$matches) > 0L,
      paste0("No session has a player called \"", me(), "\". Names in this bundle: ",
             paste(bundle_players(bundle()), collapse = ", "), ".")
    ))
    bundle_derived(t)
  })

  output$status <- renderUI({
    if (!nzchar(me())) return(NULL)
    if (!prime$ready) {
      return(tags$p(class = "small", sprintf("Reading session %d of %d...", min(prime$done + 1L, prime$total), prime$total)))
    }
    msgs <- list()
    if (source_kind() == "sample") {
      msgs <- c(msgs, list(tags$p(class = "small text-body-secondary",
        "Showing a synthetic sample. Choose your bundle (step 1) or add a session (step 2) to see your own.")))
    }
    sk <- tables()$skipped
    if (nrow(sk) > 0L && nrow(tables()$matches) > 0L) {
      msgs <- c(msgs, list(tags$p(class = "small text-warning",
        sprintf("%d session(s) left out: %s.", nrow(sk), paste(unique(sk$reason), collapse = "; ")))))
    }
    tagList(msgs)
  })

  observeEvent(derived(), {
    d <- derived()$sessions$session_date
    hi <- max(d)
    lo <- min(d)
    updateSliderInput(session, "range", min = lo, max = max(hi, lo + 1), value = c(max(hi - 91, lo), max(hi, lo + 1)))
  })

  # ---- outputs ------------------------------------------------------------
  draw <- function(fn, ...) renderPlot(fn(derived(), ...), bg = "transparent", res = 96)
  output$plot_trend <- renderPlot(
    plot_session_trend(derived(), date_range = input$range), bg = "transparent", res = 96
  )
  output$plot_rally <- draw(plot_rally_length)
  output$plot_speed <- draw(plot_stroke_speed)
  output$plot_net <- draw(plot_net_clearance)
  output$plot_gap <- draw(plot_gap_distribution)

  output$summary <- renderTable({
    d <- derived()
    s <- d$sessions
    two_col(
      c("Sessions (days)", "Recordings", "Your strokes tracked", "First session", "Last session",
        "Rallies kept after corrections"),
      c(nrow(s), sum(s$n_parts), sum(d$tables$shot_detail$player == "guest"),
        format(min(s$session_date)), format(max(s$session_date)),
        if (is.null(d$corrected_rallies)) 0L else nrow(d$corrected_rallies))
    )
  }, spacing = "xs")

  output$sessions <- renderTable({
    s <- derived()$sessions
    tibble::tibble(
      Date = format(s$session_date), Recordings = s$n_parts,
      `Your strokes` = s$me_shots, `Accuracy (%)` = s$shots_in_pct, `Minutes` = s$duration_min
    )
  }, spacing = "xs", digits = 1)

  output$merge_msg <- renderUI({
    r <- merge_result()
    if (is.null(r)) tags$p("Nothing merged yet.") else tags$p(r$msg)
  })
  output$merge_summary <- renderTable({
    r <- merge_result()
    req(r)
    n <- length(bundle()$sessions)
    rep <- r$report
    count <- function(a) if (is.null(rep)) 0L else sum(rep$action == a)
    two_col(
      c("Sessions in bundle", "Added", "Replaced by a newer copy", "Kept (existing is newer)", "Unchanged"),
      c(n, count("added"), count("replaced"), count("kept"), count("unchanged"))
    )
  }, spacing = "xs")
  output$merge_table <- renderTable({
    r <- merge_result()
    req(r, r$report)
    tibble::tibble(`Match` = format(r$report$match_id, scientific = FALSE), Action = r$report$action)
  }, spacing = "xs")
}

shinyApp(ui, server)
