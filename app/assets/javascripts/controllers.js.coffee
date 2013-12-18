ForeCiteControllers = angular.module('ForeCite.controllers', [])

# This is for testing only
# Maybe use it for a welcome page later
ForeCiteControllers.controller "HelloCtrl", ($scope) ->
  $scope.greeting = "hello!!! welcome!"

ForeCiteControllers.controller 'LinksController', ($scope, $http, $resource, $location) ->

  $scope.getValidQuery = (query, button) ->
    $scope.buttonSelected = button
    ajaxReq = $http.get("/links/boss/" + query)

    ajaxReq.success (data) ->
      $scope.searchResults = true
      $scope.divSelected = false
      $scope.validQueries = data

  $scope.executeButton = (query) ->
    $scope.searchQuery = query
    $scope.getLinks()                         if $scope.buttonSelected == "links"
    $scope.getCategories($scope.searchQuery)  if $scope.buttonSelected == "categories"
    $scope.getBooks()                         if $scope.buttonSelected == "books"
    $scope.searchResults = false

  $scope.getLinks = ->
    extlinks = $http.jsonp 'http://en.wikipedia.org//w/api.php?action=query&prop=extlinks&format=json&ellimit=200&titles=' + $scope.searchQuery + '&callback=JSON_CALLBACK'
    extlinks.success (data) ->
      $scope.links = data.query.pages[_.first _.keys data.query.pages].extlinks

      domainsList = []
      parser = document.createElement("a")
      for link in $scope.links
        link["*"] = "http:" + link["*"] if /^\/\//i.test(link["*"])
        parser.href = link["*"]
        domainsList.push parser.host

      $scope.domainsList = _.unique(domainsList)

      $location.path("/links").replace()
      $scope.divSelected = true

  $scope.getCategories = (query) ->

    categories = $http.jsonp 'http://en.wikipedia.org//w/api.php?action=query&prop=categories&format=json&clshow=!hidden&cllimit=100&titles=' + (query) + '&callback=JSON_CALLBACK'
    categories.success (data) ->

      $scope.cats = data.query.pages[_.first _.keys data.query.pages].categories
      ele = angular.element('#search-query')
      ele.scope().searchQuery = query
      ele.val(query)
      ele.scope().wikifiedQuery = "http://en.wikipedia.org/wiki/" + ele.scope().searchQuery.split(" ").join("_")
      $location.path("/categories").replace()
      $scope.divSelected = true

      for element in $scope.cats                     # This loop removes "Category:" from every string
        element.title = element.title.split(":").pop()

  $scope.getTopics = (category) ->
    subcats = $http.jsonp 'http://en.wikipedia.org//w/api.php?action=query&list=categorymembers&format=json&cmtitle=' + category + '&cmlimit=400&callback=JSON_CALLBACK'
    subcats.success (data) ->
      $scope.topics = data.query.categorymembers
      $scope.currentCategory = category.split(":").pop()

  $scope.getBooks = ->
    $scope.amazons = null
    $scope.currentBookTitle = null

    ajaxReq = $http.get("/links/search/" + $scope.searchQuery)
    ajaxReq.success (data) ->
      $scope.books = data
      $scope.amazonSearch($scope.searchQuery)
      $location.path("/books").replace()
      $scope.divSelected = true

  $scope.getAmazon = (books_array) ->                 # Refactor: Clean this up since we're now only sending one, not an array
    isbns = []
    for book in books_array
      isbn = book.split("ISBN")[1].replace("-", "").replace("-", "").replace("-", "").replace(".", "")
      isbns.push($.trim(isbn))
    isbn_string = isbns.join("-")

    ajaxReq = $http.get("/links/products/" + isbn_string)
    ajaxReq.success (data) ->
      $scope.currentWikiBook = data

  $scope.showBookTitle = (title) ->
    $scope.currentBookTitle = title

  $scope.amazonSearch = (query) ->
    ajaxReq = $http.get("/links/amazon_search/" + query)
    ajaxReq.success (data) ->
      $scope.amazons = data

LinksController.$inject = ['$scope', '$http', '$resource', '$location']