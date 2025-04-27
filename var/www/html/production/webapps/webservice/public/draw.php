<canvas id="myCanvas" width="800" height="760" style="background: rgb(220, 237, 242); border: 1px solid gray"></canvas>
<image id="myimage" src="template1.jpg" style="border: 1px solid black;">

<script>
var c = document.getElementById("myCanvas");
var ctx = c.getContext("2d");

var img = document.getElementById("myimage");
img.onload = function() {
    console.log(arguments);
    ctx.drawImage(img, 0, 0, 300, 450);

    ctx.beginPath();
    ctx.arc(175, 85, 5, 0, 2 * Math.PI);
    ctx.lineWidth = 2;
    ctx.stroke();
}
</script>