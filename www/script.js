/* 
Converts doy to month-day string, assums not a leap-year
Doy is not stable between leap years and non-leap years
Ignore leap-years for now so use 2019, a non-leap year
*/
function monthDay(doy) {
    var startDate = new Date(2019,0,doy);
    var startStr = startDate.toString().split(' ')[1].concat('-',startDate.getDate());
    
    return startStr;
}

$(document).on("shiny:inputchanged", function(event) {
  if (event.name === "doySlider") {
   
   //need to be careful because UI, sqlite, and JS are 1-indexed (1-365, non-leap year), but R is 0-indexed (0-364, non-leap-year)

    document.getElementById("startDoy").innerHTML = monthDay(event.value[0]);
    document.getElementById("endDoy").innerHTML = monthDay(event.value[1]);
  }
});