// Set opt
marked.setOptions({
  renderer: new marked.Renderer(),
  pedantic: false,
  gfm: true,
  breaks: false,
  sanitize: false,
  smartLists: true,
  smartypants: false,
  xhtml: true
});
$(document).ready(function() {
	$("#api-doc-logo-section,#api-description-section,#contributer-section,#header-params-section,#query-params-section,#body-params-section,#request-simple-section,#response-params-section,#response-simple-section,#error-code-section,#related-read-section")
       .each(function(index, element) {
        var text = $(element).html();
		$(element).html(marked(text));
	});
	$(".language-json").each(function(index, element) {
        hljs.lineNumbersBlock(element);
        hljs.highlightBlock(element);
	});
});