' Compute the bounding box
sub bounding ()
    xmin = x[1] : xmax = x[1]
    ymin = y[1] : ymax = y[1]
    for i = 1 to count
        if x[i] < xmin then xmin = x[i]
        if x[i] > xmax then xmax = x[i]
        if y[i] < ymin then ymin = y[i]
        if y[i] > ymax then ymax = y[i]
    next i
    bbox_w = xmax - xmin
    bbox_h = ymax - ymin
end sub

' Step the points forward (or backward) in time
sub integrate (dt)
    for i = 1 to count
        x[i] = x[i] + dx[i] * dt
        y[i] = y[i] + dy[i] * dt
    next i
end sub

sub draw_word ()
    cls
    for i = 1 to count
        gotoxy x[i] - xmin, 5 + y[i] - ymin
        print "*" ;
    next i
    gotoxy 100, 100
end sub

' Read input onto the stack.
count = 0
while
    input "" ; row$
    if row$ = "" then exit while
    count = count + 1
    push row$
wend
' Make arrays for all the variables
dim x(count), y(count), dx(count), dy(count)
' Parse the input
for i = 1 to count
    pop
    x[i] = val(mid$(row$, 11, 6))
    y[i] = val(mid$(row$, 19, 6))
    dx[i] = val(mid$(row$, 37, 2))
    dy[i] = val(mid$(row$, 41, 2))
next i

bounding()

' Run until we minimize width or height
time = 0
dt = 100
while dt
    integrate(dt)
    time = time + dt
    old_bbox_w = bbox_w : old_bbox_h = bbox_h
    bounding()
    if bbox_w < 1000 or bbox_h < 1000 then dt = 10
    if bbox_w < 100 or bbox_h < 100 then dt = 1
    if old_bbox_w < bbox_w then exit while
    if old_bbox_h < bbox_h then exit while
wend
' Take a step back to the best value
integrate(-1)
time = time - 1
bounding()
draw_word()
gotoxy 0, 20
print time
exit
