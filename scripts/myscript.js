// add your JavaScript/D3 to this file

const dataURL = "https://raw.githubusercontent.com/jagriti-hirwani/EDAV-finalproject-Fall2023/main/data/Clean/layoff_cleaned_2.csv";

// Load your CSV data
d3.csv(dataURL).then(function (data) {

    // Convert date strings to JavaScript Date objects
    const parseDate = d3.timeParse("%Y-%m-%d");
    data.forEach(function (d) {
        d.Date = d["Received Date"] ? parseDate(d["Received Date"]) : null;
        console.log(d);
    });

    // Initial setup
    const margin = { top: 20, right: 40, bottom: 20, left: 40 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    const svg = d3.select("#plot")
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // Initial year
    let currentYear = 2000;

    // Update chart based on the selected year
    function updateChart(year) {
        const filteredData = data.filter(d => d.Date && d.Date.getFullYear() === year);
        console.log(filteredData);
        const reasonsCount = Array.from(
            d3.group(filteredData, d => d.layoff_type_cleaned),
            ([key, value]) => ({ Reason: key, 'Number of Workers': d3.sum(value, d => d['Number of Workers']) })
        );

        // Sort by the number of workers laid off in descending order
        reasonsCount.sort((a, b) => b['Number of Workers'] - a['Number of Workers']);

        console.log(reasonsCount);

        const top10Reasons = reasonsCount.slice(0, 10);

        const xScale = d3.scaleBand()
            .domain(top10Reasons.map(d => d.Reason))
            .range([0, width])
            .padding(0.1);

        const yScale = d3.scaleLinear()
            .domain([0, d3.max(top10Reasons, d => d['Number of Workers'])])
            .range([height, 0]);

        svg.selectAll("*").remove(); // Clear previous chart

        // Draw bars
        svg.selectAll("rect")
            .data(top10Reasons)
            .enter().append("rect")
            .attr("x", d => xScale(d.Reason))
            .attr("y", d => yScale(d['Number of Workers']))
            .attr("width", xScale.bandwidth())
            .attr("height", d => height - yScale(d['Number of Workers']))
            .attr("fill", "steelblue");
        // Add axes
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(xScale));

        svg.append("g")
            .call(d3.axisLeft(yScale));

        // Add labels
        svg.append("text")
            .attr("transform", "translate(" + (width / 2) + " ," + (height + margin.top) + ")")
            .style("text-anchor", "middle")
            .text("Reason for Layoff");

        svg.append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 0 - margin.left)
            .attr("x", 0 - (height / 2))
            .attr("dy", "0.8em")
            .style("text-anchor", "middle")
            .text("Number of Workers Laid Off");

        svg.append("text")
            .attr("x", (width / 2))
            .attr("y", 0 - (margin.top / 2))
            .attr("text-anchor", "middle")
            .style("font-size", "16px")
            .style("text-decoration", "underline")
            .text("Top 10 Reasons for Layoff in " + year);
    }

    // Initial chart setup
    updateChart(currentYear);

    // Automatically change the year every second
    setInterval(function () {
        currentYear += 1;
        if (currentYear > 2024) {
            currentYear = 2000; // Reset to the initial year
        }
        updateChart(currentYear);
    }, 2000);

});
