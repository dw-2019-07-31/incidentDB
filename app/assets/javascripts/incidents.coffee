# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  # console.log("ugoiteruyo")
  $table = $('.table')
  $table.floatThead autoReflow:'false',responsiveContainar: ($table) ->
    $table.closest '.table-responsive'
