$(() => {
  $('#order-sheet').hide()
  window.addEventListener('message', event => {
    const item = event.data
    if (item.action === 'show') {
      $('#order-sheet').show()
      console.log(item)
    } else {
      $('#order-sheet').hide()
    }
  }, false)
})
