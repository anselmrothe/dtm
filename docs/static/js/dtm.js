$(document).ready(function() {

    // ============ general functions ============



    // ============ search field ============

    // "static/lib/bootstrap3-typeahead.min.js"
    // https://github.com/bassjobsen/Bootstrap-3-Typeahead

    $.get("data/paper_titles.json", function(data) {

        var $searchfield = $("#searchfield .typeahead")

        $searchfield.typeahead({
            minLength: 1,
            autoSelect: true,
            highlight: true,
            name: 'my-dataset',
            // source: ["item1","item2","item3"]
            // source: substringMatcher(["item1","item2","item3"])
            source: substringMatcher(data),
            callback: {
                onInit: function(node) {
                    console.log('Typeahead Initiated on ' + node.selector);
                }
            }
        });

        $searchfield.change(function() {
            var suggestion = $searchfield.typeahead("getActive");
            populate_similar_papers_table(suggestion);
            // var textbox = $searchfield.val();
            // console.log('suggestion ' + suggestion);
            // console.log('textbox ' + textbox);
            // if (suggestion) {
            //     if (suggestion == textbox) {
            //         console.log('happy');
            //         populate_similar_papers_table(textbox);
            //     }
            // }
        });

    }, 'json');

    var substringMatcher = function(strs) {
        return function findMatches(q, cb) {
            var matches, substringRegex;

            // an array that will be populated with substring matches
            matches = [];

            // regex used to determine if a string contains the substring `q`
            substrRegex = new RegExp(q, 'i');

            // iterate through the pool of strings and for any string that
            // contains the substring `q`, add it to the `matches` array
            $.each(strs, function(i, str) {
                if (substrRegex.test(str)) {
                    matches.push(str);
                }
            });

            cb(matches);
        };
    };

    // ============ similar papers table ============

    var populate_similar_papers_table = function(paper_title) {

        var json_file = 'data/similar_papers/' + paper_title + '.json';

        // clear the table div
        d3.select('#similar_papers_table').html(null);

        d3.json(json_file, function(error, data) {

            function tabulate(data, columns) {
                var table = d3.select('#similar_papers_table')
                    .append('table')
                    .attr("class", "table")
                    .attr("id", paper_title);

                var thead = table.append('thead');
                var tbody = table.append('tbody');

                // append the header row
                thead.append('tr')
                    .selectAll('th')
                    .data(columns).enter()
                    .append('th')
                    .text(function(column) { return column; });

                // create a row for each object in the data
                var rows = tbody.selectAll('tr')
                    .data(data)
                    .enter()
                    .append('tr');

                // create a cell in each row for each column
                var cells = rows.selectAll('td')
                    .data(function(row) {
                        return columns.map(function(column) {
                            return { column: column, value: row[column] };
                        });
                    })
                    .enter()
                    .append('td')
                    .text(function(d) { return d.value; });

                return table;
            };

            // render the table(s)
            tabulate(data, ['Similarity', 'Year', 'Title']); // 2 column table
        });
    };

    // ============ debug ============

    var debug = function() {
        document.getElementById("choose").style.backgroundColor = "#d6eaf8";

        var p = d3.select("#debug")
            .selectAll("div")
            .data([1, 2, 3])
            .enter()
            .append("div")
            .text(function(d) { return d; });

        d3.json("data/paper_titles.json", function(error, data) {
            var choose = d3.select("#debug")
                .selectAll("x")
                .data(data)
                .enter()
                .append("div")
                .text(function(d) { return d; })
                .attr("id", "klaus");
        });
    };
    // debug();

    // ============ outdated ============

    var populate_paper_dropdown_list = function() {
        d3.json("data/paper_titles.json", function(error, data) {
            var choose = d3.select("#paper_dropdown_list")
                .selectAll("a")
                .data(data)
                .enter()
                .append("a")
                .text(function(d) { return d; })
                .attr("class", "dropdown-item")
                // .attr("href", "javascript:return false;")
                .attr("href", "#paper_dropdown_list")
                .on('click', function(d) {
                    populate_similar_papers_table(d);
                });
        });
    };

});