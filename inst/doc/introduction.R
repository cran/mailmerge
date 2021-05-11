## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------

## ----input-data---------------------------------------------------------------
dat <-  data.frame(
  email      = c("friend@example.com", "foe@example.com"),
  first_name = c("friend", "foe"),
  thing      = c("something good", "something bad"),
  stringsAsFactors = FALSE
)


## ----markdown-message---------------------------------------------------------
msg <- '
---
subject: "**Hello, {first_name}**"
---

Hi, **{first_name}**

I am writing to tell you about **{thing}**.

{if (first_name == "friend") "Regards" else ""}


Me
'

## ----library------------------------------------------------------------------

library(mailmerge)
library(gmailr, quietly = TRUE, warn.conflicts = FALSE)

if (interactive()) {
  # Note: you should always authenticate. The 'interactive()` condition only 
  # prevents execution on the CRAN servers
  gm_auth()
}

## ----mail-merge---------------------------------------------------------------
dat %>% 
  mail_merge(msg)

if (interactive()) {
  dat %>%
    mail_merge(msg) %>%
    print()
}

## ---- echo=FALSE--------------------------------------------------------------
knitr::include_graphics("../man/figures/mail-merge.gif")

