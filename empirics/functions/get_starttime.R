get_starttime = function(time){
  starttime  = c(floor(time[1]), 1+(time[1]-floor(time[1]))/0.25)
  starttime2 = starttime
  if(max(tcode_lag) == 4) starttime2[1] = starttime2[1] + 1
  if(max(tcode_lag) == 1){
    if(starttime2[2] < 4)  starttime2[2] = starttime2[2] + 1
    if(starttime2[2] == 4){
      starttime2[1] = starttime2[1] + 1
      starttime2[2] = 0
    }
  }
  
  return(list(starttime,starttime2))
}