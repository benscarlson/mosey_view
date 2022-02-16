

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
