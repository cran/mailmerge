#' Merges data into an email and send.
#'
#' @description 
#' 
#' `r lifecycle::badge("experimental")`
#' 
#' Merges columns from a data frame into a markdown document using the
#' [glue::glue_data()] function. The markdown can contain a yaml header for
#' subject and cc line.
#' 
#' Note that only 'gmail' is supported at the moment, via [gmailr::gm_send_message].
#' 
#' Before using `mail_merge()`, you must be authenticated to the gmail service. 
#' Use [gmailr::gm_auth()] to authenticate prior to starting the mail merge.
#' 
#'
#' @param data A data frame or `tibble` with all the columns that should be
#'   glued into the message. Substitution is performed using
#'   [glue::glue_data()]`
#'
#' @param message A list with components `yaml` and `body`.  You can use
#'   [mm_read_message()] or [mm_read_message_googledoc()] to construct a
#'   message in this format.
#'
#' @param to_col The name of the column in `data` that contains the email
#'   address to send the message to.
#'
#' @param send A character string, one of:
#' * "preview" : displays message in viewer without sending mail
#' * "draft : writes message into "drafts" folder on gmail
#' * "immediately" : sends email
#' 
#' @param confirm If `TRUE` sends email without additional confirmation.
#'   If `FALSE` asks for confirmation before sending.
#'
#' @param sleep_preview If `send == "preview"` the number of seconds to sleep
#'   between each preview. See also [preview_mailmerge]
#'
#' @param sleep_send If `send == "immediately"` the number of seconds to sleep between
#'   each email send (to prevent gmail API 500 errors).
#'
#' @importFrom purrr map pmap
#' @export
#'
#' @return Returns a list for every message, consisting of:
#' * `msg`: The message in `mime` format
#' * `id`: The `gmailr` response id
#' * `type`: preview, draft or sent
#' * `success`: TRUE if the message was sent successfully
#'   
#' @example inst/examples/example_mail_merge.R
#' 
#' @seealso [preview_mailmerge]
#'   
mail_merge <- function(data, message, to_col = "email", send = c("preview", "draft", "immediately"),
                       confirm = FALSE, 
                       sleep_preview = 1, sleep_send = 0.1
){
  
  send <- match.arg(send)
  
  preview <- identical(send, "preview")
  draft   <- identical(send, "draft")
  
  if (send != "preview" && !gmailr::gm_has_token()) {
    stop(
      "You must authenticate with gmailr first.  Use `gmailr::gm_auth()", 
      call. = FALSE
    )
  }
  
  if(nrow(data) == 0) {
    warning("nothing to email")
    return(invisible(data))
  }
  
  if(is.null(data[[to_col]])) {
    stop("'data' must contain an 'email' column, or specify a 'to_col'")
  }
  
  
  msg <- mm_read_message(message)
  
  if(!preview && !confirm) {
    confirm_msg <- paste0("Send ", nrow(data), " emails (", send, ")?")
    cat(confirm_msg)
    if (yesno()) {
      return(invisible())
    }
  }
  
  z <- data %>%
    purrr::pmap(list) %>%
    purrr::map(function(x) {
      
      glued_data <-  glue_mail(x, msg)
      
      args <- list(
        to         = x[[to_col]],
        body       = glued_data[["body"]],
        subject    = glued_data[["subject"]],
        cc         = glued_data[["cc"]]
      )
      
      if (preview) {
        do.call(mm_preview_mail, args)
      } else {
        Sys.sleep(sleep_send)
          args <- append(args, list(draft = draft))
        if (draft) {
          do.call(mm_send_draft, args)
        } else {
          do.call(mm_send_mail, args)
        }
      }
    })
  
  
  if (preview) {
    base::message("Sent preview to viewer")
    class(z) <- "mailmerge_preview"
    attr(z, "sleep") <- sleep_preview
  } else {
    n_messages <- vapply(z, function(x) isTRUE(x$success), FUN.VALUE = logical(1)) %>% sum()
    if (draft) {
      base::message("Sent ", n_messages, " messages to your draft folder")
    } else {
      base::message("Sent ", n_messages, " messages to email")
    }
  }
  z
}

#' @export
print.mailmerge_preview <- function(x, ...) { # nocov start
  purrr::walk(x, function(xx){
    in_viewer(xx)
    Sys.sleep(attr(x, "sleep"))
  }
  )
} # nocov end

