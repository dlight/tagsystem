function f(key, s) {
    $(document).bind('keyup', key, function() {
        document.location = $('a#' + s).attr("href")
    });
}

f('u', 'up');
f('n', 'next');
f('p', 'prev');

f('h', 'hi');
f('m', 'mid');
f('l', 'low');