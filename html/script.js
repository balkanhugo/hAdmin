NUI3D = {};

window.addEventListener('message', function (event) {
    let data = event.data
    if (data.text == undefined) {data.action = "hide"}

    if ( !$(`#${data.id}`).length) {
        $("#container1").append(`
            <div class="doorlock" id = ${data.id}></div>
        `)
    }

    $(`#${data.id}`).html(data.text);
    $(`#${data.id}`).css({ "left": (data.x * 100) + '%', "top": (data.y * 100) + '%' });

    if (NUI3D[data.id]) clearTimeout(NUI3D[data.id]);

    NUI3D[data.id] = setTimeout(function(){
        $(`#${data.id}`).remove()
    }, 200)
})