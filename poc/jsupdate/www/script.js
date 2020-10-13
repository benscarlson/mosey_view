/* 
Converts doy to month-day string
Doy is not stable between leap years and non-leap years, need to handle this somehow
2020 is a leap year, so use 2019, a non-leap year instead
*/
function monthDay(doy) {
    var startDate = new Date(2019,0,doy);
    var startStr = startDate.toString().split(' ')[1].concat('-',startDate.getDate());
    
    return startStr;
}

$(document).on("shiny:inputchanged", function(event) {
  if (event.name === "doySlider") {
   
    document.getElementById("startDoy").innerHTML = monthDay(event.value[0]);
    document.getElementById("endDoy").innerHTML = monthDay(event.value[1]);
  }
});