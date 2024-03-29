% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mail_merge.R
\name{mail_merge}
\alias{mail_merge}
\title{Merges data into an email and send.}
\usage{
mail_merge(
  data,
  message,
  to_col = "email",
  send = c("preview", "draft", "immediately"),
  confirm = FALSE,
  sleep_preview = 1,
  sleep_send = 0.1
)
}
\arguments{
\item{data}{A data frame or \code{tibble} with all the columns that should be
glued into the message. Substitution is performed using
\code{\link[glue:glue]{glue::glue_data()}}`}

\item{message}{A list with components \code{yaml} and \code{body}.  You can use
\code{\link[=mm_read_message]{mm_read_message()}} or \code{\link[=mm_read_message_googledoc]{mm_read_message_googledoc()}} to construct a
message in this format.}

\item{to_col}{The name of the column in \code{data} that contains the email
address to send the message to.}

\item{send}{A character string, one of:
\itemize{
\item "preview" : displays message in viewer without sending mail
\item "draft : writes message into "drafts" folder on gmail
\item "immediately" : sends email
}}

\item{confirm}{If \code{TRUE} sends email without additional confirmation.
If \code{FALSE} asks for confirmation before sending.}

\item{sleep_preview}{If \code{send == "preview"} the number of seconds to sleep
between each preview. See also \link{preview_mailmerge}}

\item{sleep_send}{If \code{send == "immediately"} the number of seconds to sleep between
each email send (to prevent gmail API 500 errors).}
}
\value{
Returns a list for every message, consisting of:
\itemize{
\item \code{msg}: The message in \code{mime} format
\item \code{id}: The \code{gmailr} response id
\item \code{type}: preview, draft or sent
\item \code{success}: TRUE if the message was sent successfully
}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Merges columns from a data frame into a markdown document using the
\code{\link[glue:glue]{glue::glue_data()}} function. The markdown can contain a yaml header for
subject and cc line.

Note that only 'gmail' is supported at the moment, via \link[gmailr:gm_send_message]{gmailr::gm_send_message}.

Before using \code{mail_merge()}, you must be authenticated to the gmail service.
Use \code{\link[gmailr:gm_auth]{gmailr::gm_auth()}} to authenticate prior to starting the mail merge.
}
\examples{
## ---- input-data --------------------------------------------------------

dat <-  data.frame(
  email      = c("friend@example.com", "foe@example.com"),
  first_name = c("friend", "foe"),
  thing      = c("something good", "something bad"),
  stringsAsFactors = FALSE
)

## ---- markdown-message --------------------------------------------------

msg <- '
---
subject: "**Hello, {first_name}**"
---

Hi, **{first_name}**

I am writing to tell you about **{thing}**.

{if (first_name == "friend") "Regards" else ""}


Me
'


## ---- mail-merge --------------------------------------------------------

dat \%>\% 
  mail_merge(msg)

if (interactive()) {
  dat \%>\%
    mail_merge(msg) \%>\%
    print()
}

## ---- display shiny gadget ----------------------------------------------

if (interactive()) {
  dat \%>\%
    mail_merge(msg) \%>\%
    preview_mailmerge()
}
}
\seealso{
\link{preview_mailmerge}
}
