function open_in_new_window(link) {
    window.open(link);
    return false;
}

function add_attachment(adder) {
    var attachment = adder.parentNode;
    attachment.parentNode.insertBefore(attachment.cloneNode(true), attachment.nextSibling);
    attachment.removeChild(adder);
    return false;
}

function stop_propagation(event) {
    if (event.stopPropagation) event.stopPropagation();
    event.cancelBubble = true;

    if (event.preventDefault) event.preventDefault();
    else event.returnValue = false;
}

function start_controlpanel_resize(event) {
    var controlpanel = document.getElementById('controlpanel');
    var content = document.getElementById('content');
    function drag(event) {
        controlpanel.style.width = event.client.x + 'px';
        content.style.left = event.client.x + 'px';
    }
    function drop(event) {
        document.removeEvent('mousemove', drag);
        document.removeEvent('mouseup', drop);
        Cookie.write('control_panel_width', event.client.x, {duration: 365});
    }
    document.addEvents({mousemove: drag, mouseup: drop});
    stop_propagation(event);
}

function start_message_view_resize(event) {
    var messages_pane   = document.getElementById('messages_pane');
    var message_view    = document.getElementById('message_view');
    var message_divider = document.getElementById('message_divider');
    function drag(event) {
        messages_pane.style.bottom = messages_pane.parentNode.offsetHeight - event.client.y + 'px';
        message_view.style.top = event.client.y + 'px';
        message_divider.style.top = event.client.y + 'px';
    }
    function drop(event) {
        document.removeEvent('mousemove', drag);
        document.removeEvent('mouseup', drop);
        Cookie.write(document.getElementById('content').classList.contains('message_display') ? 'message_divider_message_display_top' : 'message_divider_top', event.client.y, {duration: 365});
    }
    document.addEvents({mousemove: drag, mouseup: drop});
    stop_propagation(event);
}

var touch_enabled = false;

function check_touch_event_support(){
    try {
        document.createEvent("TouchEvent");
        return true;
    } catch(e) {
        return false;
    }
}

window.addEvent('load', function() {
    touch_enabled = check_touch_event_support();

    if (!touch_enabled) { document.querySelector('#controlpanel .activeborder').addEventListener('mousedown', start_controlpanel_resize, false); }

    var control_panel_width = Cookie.read('control_panel_width')
    if (control_panel_width) {
        document.getElementById('controlpanel').style.width = control_panel_width + 'px';
        document.getElementById('content').style.left = control_panel_width + 'px';
    }

    var message_divider = document.getElementById('message_divider');
    if (message_divider) {
        if (!touch_enabled) { message_divider.addEvent('mousedown', start_message_view_resize); }


        var message_divider_top = Cookie.read('message_divider_top');
        if (document.getElementById('messages_pane') && message_divider_top) {
            document.getElementById('messages_pane').style.bottom = document.getElementById('messages_pane').parentNode.offsetHeight - message_divider_top + 'px';
            document.getElementById('message_view').style.top     = message_divider_top + 'px';
            message_divider.style.top  = message_divider_top + 'px';
        }
    }

});


