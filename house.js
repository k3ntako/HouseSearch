//https://www.w3schools.com/howto/howto_js_slideshow.asp

var slideIndex = 1;
var IDnum = 1;
var slideIndex = Array.apply(null, Array(25)).map(Number.prototype.valueOf,1);


/**
for (j = 1; j < 3, j++){
	window.alert(j)
	showSlides(slideIndex, j);
}**/



function plusSlides(n,slideID) {
  showSlides(slideIndex[slideID] += n,slideID);
}

function currentSlide(n,slideID) {
  showSlides(slideIndex[slideID] = n,slideID);
}

function showSlides(n,slideID) {
  var i;
  var name_of_class = "mySlides".concat(slideID);
  var slides = document.getElementsByClassName(name_of_class);
  /*window.alert(name_of_class)*/
  var dots = document.getElementsByClassName("dot");
  if (n > slides.length) {slideIndex[slideID] = 1} 
  if (n < 1) {slideIndex[slideID] = slides.length}
  for (i = 0; i < slides.length; i++) {
      slides[i].style.display = "none"; 
  }
  for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(" active", "");
  }
  slides[slideIndex[slideID]-1].style.display = "block"; 
  dots[slideIndex[slideID]-1].className += " active";
}




