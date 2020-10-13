

# tst <- tibble(Group=rep(c('A','B'),each=4),Names=letters[1:8],Values=1:8)
# 
# listTree(tst)

# z <- as.list(1:3)
# names(z) <- letters[1:3]
# z %>% map(~{. * 2})
# 
# dat <- x$data[[1]]

# tst <- tibble(
#   Group1=rep(c('A','B'),each=4),
#   Group2=rep(c('C','D','E','F'),each=2),
#   Names=letters[1:8],
#   Values=1:8)

#' Recursively walks down the columns of a dataframe
#' Making nested groups
listTree <- function(dat) {
  if(ncol(dat) > 2) {
    x <- dat %>% nest(data=-1)
    lst <- as.list(x[[2]])
    names(lst) <- x[[1]]
    lst %>% map(listTree)
  } else if(ncol(dat)==2) {
    lst<-as.list(dat[[2]])
    names(lst)<-dat[[1]]
    return(lst)
  } else if(ncol<2) {
    stop('ERROR')
  }
}

# #only works for three levels. could make this more general by making it recursive.
# #splits by each consequtive column to make nested lists of lists
# listTree <- function(dat) {
#   lstTree <- lapply(split(dat,dat[[1]]),function(dat) { #note the 'x' here is a dataframe
#     dat <- dat[-1]
#     lapply(split(dat,dat[[1]]),function(dat) {
#       dat <- dat[-1]
#       return(sapply(dat[[1]],simplify=FALSE,USE.NAMES=TRUE,function(x){''}))
#     })
#   })
# 
#   return(lstTree)
# }