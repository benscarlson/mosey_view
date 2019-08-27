library(purrr)
library(tidyr)
library(tibble)

dat <- data.frame(
  col1=rep(c('a','b'),each=4),
  col2=rep(c('p','q'),each=2),
  col3=c('x','y'),
  stringsAsFactors = FALSE) #note b recycles

#try building on this:
s <- split(dat,dat$a)
a <- lapply(s[[1]]$b,function(x) {x})
names(a) <- s[[1]]$b

lapply(dat,function(r) {
  print(r)
})

dat <- data.frame(a=rep('a',3),b=rep(1:3))

dat %>% group_by(a) %>% map(~lst(.))

map(dat$b,function(x) {
  return(x)
})
names()

~lst(`.`=''))

list('1'='','2'='','3'='')

#do something like this to make it recursive
datToListTree <- function(dat) {
  lapply(split(dat,dat[[1]]),function(x) { #the 'x' here is a dataframe
    #print(str(x))
    #return(x[[2]])
    if(ncol==2) {
      return(sapply(x[[2]],simplify=FALSE,USE.NAMES=TRUE,function(x){x})) #x[[2]]
    } else {
      x <- x[-1]
      datToListTree(x)
    }
  })
}

lapply(split(dat,dat[[1]]),function(x) { #the 'x' here is a dataframe
  x <- x[-1]
  lapply(split(x,x[[1]]),function(x) {
    x <- x[-1]
    return(sapply(x[[1]],simplify=FALSE,USE.NAMES=TRUE,function(x){x}))    
  })
})
