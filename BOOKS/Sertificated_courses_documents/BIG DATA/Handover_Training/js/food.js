/*This software is released under the MIT License

MIT License 2014 Denes Csala http://www.csaladen.es

The following software uses the javascript frameworks below,
all of which are distributed under the MIT or GNU/GPL license:
D3.js http://d3js.org/  data-oriented javascript framework. 
	- Sankey plugin http://bost.ocks.org/mike/sankey/ for D3.js (modified) by Mike Bostock, 
	  which is based on the initial version http://tamc.github.io/Sankey/ by Thomas Counsell. 
	  I have incorporated the ability to render Sankey cycles, as pioneered by https://github.com/cfergus
	- Dragdealer.js href="http://skidding.github.io/dragdealer/ by Ovidiu Chereches
*/

//<!--DATA INIT-->

var data={"nodes": [], "links": []}

//<!--DATA ENTRY-->

nodesform=d3.select("#nodes-form");
function addnode() {
	nodesform.append("div").append("input").attr("value",'{"name":"New Node"}');
}
function removenode() {
	nodesform[0][0].children[nodesform[0][0].children.length-1].remove("div")
}
linksform=d3.select("#links-form");
function addlink() {
	linksform.append("div").append("input").attr("value",'{"source":0,"target":1,"value":0.52}');
}
function removelink() {
	linksform[0][0].children[linksform[0][0].children.length-1].remove("div")
}
function draw() {
	
	data={"nodes": [], "links": []}
	
	for (i = 0; i < nodesform[0][0].children.length; i++) {
		data.nodes.push(JSON.parse(nodesform[0][0].children[i].children[0].value));
	}
	for (i = 0; i < linksform[0][0].children.length; i++) {
		data.links.push(JSON.parse(linksform[0][0].children[i].children[0].value));
	}
	
	d3.json("input/real_deep.json", function(error, json) {
	  if (error) return console.warn(error);
	  //sankeyDraw(json);
	  change(json);
	});
	
	//change(data);
}
function save(){
	d3.select('#save').style('z-index',100).transition().style('opacity',0.9);
	st='{"nodes":['
	for (i = 0; i < nodesform[0][0].children.length; i++) {
		st=st+nodesform[0][0].children[i].children[0].value+',';
	}
	st=st.substring(0, st.length - 1)+'],"links":[';
	for (i = 0; i < linksform[0][0].children.length; i++) {
		st=st+linksform[0][0].children[i].children[0].value+',';
	}
	st = st.substring(0, st.length - 1)+']}';
	d3.select('#savetext').text(st);
}
function load(){
	d3.select('#load').style('z-index',100).transition().style('opacity',0.9);
}
function loadsubmit(){
	d3.select('#load').transition().style('opacity',0).style('z-index',-1);
	var loadtext=d3.select('#load')[0][0].children[1].value;
	if (loadtext!="") {
		//redraw
		var newdata=JSON.parse(loadtext);
		change(newdata);
		//remove existing node entry boxes
		var n=nodesform[0][0].children.length;
		for (i = 0; i < n; i++) {
			nodesform[0][0].children[0].remove("div");
		}
		//remove existing link entry boxes
		var n=linksform[0][0].children.length;
		for (i = 0; i < n; i++) {
			linksform[0][0].children[0].remove("div");
		}
		//add new node entry boxes
		var newdata2=JSON.parse(loadtext.substring(loadtext.indexOf('"nodes":[')+8, loadtext.indexOf('"links":[')-1));
		for (i = 0; i < newdata2.length; i++) {
			nodesform.append("div").append("input").attr("value",JSON.stringify(newdata2[i]));
		}
		//add new link entry boxes
		var newdata2=JSON.parse(loadtext.substring(loadtext.indexOf('"links":[')+8, loadtext.length - 1))
		for (i = 0; i < newdata2.length; i++) {
			linksform.append("div").append("input").attr("value",JSON.stringify(newdata2[i]));
		}
	}
}

//<!--SANKEY DIAGRAM-->

var padding = 28;
var paddingmultiplier = 50;
var lowopacity = 0.3;
var highopacity = 0.7;
var format2Number = d3.format(",.2f"),
    formatNumber = d3.format(",.0f"),
    format = function(a) {
        return formatNumber(a)
    },
    format2 = function(a) {
        return format2Number(a)
    },
    color = d3.scale.category20();
d3.select("#chart").style("width", document.getElementById("chart").offsetWidth - sizecorrection)
d3.select("#titlebar").style("width", document.getElementById("titlebar").offsetWidth - sizecorrection)
var margin = {
        top: 70,
        right: 10,
        bottom: 30,
        left: 40
    },
    width = document.getElementById("chart").offsetWidth - margin.left - margin.right,
    height = document.getElementById("chart").offsetHeight - margin.bottom - 90;
var svg = d3.select("#chart").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
var sankey = d3.sankey().nodeWidth(30).nodePadding(padding).size([width, height]);
var path = sankey.reversibleLink();
var change = function() {};

change = function(d) {
					
	padding = paddingmultiplier * (1 - densityslider.getValue()[0]) + 3
	svg.selectAll("g").remove();
	sankey = d3.sankey().nodeWidth(30).nodePadding(padding).size([width, height]);
	sankey.nodes(d.nodes).links(d.links).layout(500);
	var g = svg.append("g") //link
		.selectAll(".link").data(d.links).enter().append("g").attr("class", "link").sort(function(j, i) {
			return i.dy - j.dy
		});
	var h = g.append("path") //path0
		.attr("d", path(0));
	var f = g.append("path") //path1
		.attr("d", path(1));
	var e = g.append("path") //path2
		.attr("d", path(2));
	g.attr("fill", function(i) {
			if (i.source.fill) return i.source.fill;
								else return i.source.color = color(i.source.name.replace(/ .*/, ""))
		}).attr("opacity", lowopacity).on("mouseover", function(d) {
			d3.select(this).style('opacity', highopacity);
		}).on("mouseout", function(d) {
			d3.select(this).style('opacity', lowopacity);
		}).append("title") //link
		.text(function(i) {
			return i.source.name + " → " + i.target.name + "\n" + format2(i.value)
		});
	var c = svg.append("g") //node
		.selectAll(".node").data(d.nodes).enter().append("g").attr("class", "node").attr("transform", function(i) {
			return "translate(" + i.x + "," + i.y + ")"
		}).call(d3.behavior.drag().origin(function(i) {
			return i
		}).on("dragstart", function() {
			this.parentNode.appendChild(this)
		}).on("drag", b));
	c.append("rect") //node
		.attr("height", function(i) {
			return i.dy
		}).attr("width", sankey.nodeWidth()).style("fill", function(i) {
			if (i.fill) return i.color = i.fill;
								else return i.color = color(i.name.replace(/ .*/, ""))
		}).style("stroke", function(i) {
			return d3.rgb(i.color).darker(2)
		}).on("mouseover", function(d) {
			svg.selectAll(".link").filter(function(l) {
				return l.source == d || l.target == d;
			}).transition().style('opacity', highopacity);
		}).on("mouseout", function(d) {
			svg.selectAll(".link").filter(function(l) {
				return l.source == d || l.target == d;
			}).transition().style('opacity', lowopacity);
		}).on("dblclick", function(d) {
			svg.selectAll(".link").filter(function(l) {
				return l.target == d;
			}).attr("display", function() {
				if (d3.select(this).attr("display") == "none") return "inline"
				else return "none"
			});
		}).append("title").text(function(i) {
			return i.name + "\n" + format2(i.value)
			
		});
	c.append("text") //node
		.attr("x", -6).attr("y", function(i) {
			return i.dy / 2
		}).attr("dy", ".35em").attr("text-anchor", "end").attr("transform", null).text(function(i) {
			return i.name
		}).filter(function(i) {
			return i.x < width / 2
		}).attr("x", 6 + sankey.nodeWidth()).attr("text-anchor", "start")
	c.append("text") //node
		.attr("x", function(i) {return -i.dy / 2})
		.attr("y", function(i) {return i.dx / 2 + 6})
		.attr("transform", "rotate(270)").attr("text-anchor", "middle").text(function(i) {
			if (i.dy>50){
				return format(i.value);
			}
		}).attr("fill","white").attr("stroke","black");
		

	function b(i) { //dragmove
		if (document.getElementById("ymove").checked) {
			if (document.getElementById("xmove").checked) {
				d3.select(this).attr("transform", "translate(" + (i.x = Math.max(0, Math.min(width - i.dx, d3.event.x))) + "," + (i.y = Math.max(0, Math.min(height - i.dy, d3.event.y))) + ")")
			} else {
				d3.select(this).attr("transform", "translate(" + i.x + "," + (i.y = Math.max(0, Math.min(height - i.dy, d3.event.y))) + ")")
			}
		} else {
			if (document.getElementById("xmove").checked) {
				d3.select(this).attr("transform", "translate(" + (i.x = Math.max(0, Math.min(width - i.dx, d3.event.x))) + "," + i.y + ")")
			}
		}
		sankey.relayout();
		f.attr("d", path(1));
		h.attr("d", path(0));
		e.attr("d", path(2))
	};
};
draw();