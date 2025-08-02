.model small
.stack 100h

.data
; Stock counters for each menu item
javaChipStock      dw 10
americanoStock     dw 8
icedChaiStock      dw 12
matchaLatteStock   dw 15
blondeVanillaStock dw 7
butterCroissantStock dw 20

; Menu item prices (in Pesos)
javaChipPrice      dw 185
americanoPrice     dw 190
icedChaiPrice      dw 175
matchaLattePrice   dw 160
blondeVanillaPrice dw 175
butterCroissantPrice dw 150

; Cart holds quantity for each menu item (6 items)
cart db 6 dup(0)
; Total price of items currently in cart
total dw 0
; Accumulates total sales for whole session
totalSales dw 0

; Strings for login panel UI
loginPanel1 db 10,13, '   .------------------------.  $'
loginPanel2 db 10,13, '   |   21Cafe Login Panel   |  $'
loginPanel3 db 10,13, '   `------------------------''  $'
loginPanel4 db 10,13, '    Please enter your password $'

askPassword db 10,13, '   Password: $'
wrongPassword db 10,13, '   Incorrect password. Please try again.', 10, '$'
greetingMessage db 13,10,10,' Welcome to 21Cafe! $'
buffer db 100 dup(0)
passwordInput db 16 dup(0)
; Actual password for login (null-terminated)
password db 'progproj',0

; Main menu text
mainMenu db 10,10,10
        db '   .------------------------. ',10
        db '   |     21Cafe System      | ',10
        db '   `------------------------'' ',10
        db '          Main Menu           ',10
        db '   ------------------------   ',10
        db '    1. Purchase Menu Item     ',10
        db '    2. Total Sales            ',10
        db '    3. Manage Inventory       ',10
        db '    4. Cart                   ',10
        db '    5. Exit                   ',10
        db '   ------------------------   ',10
        db '   Please Select Your Choice: $'

; Error message for invalid input
invalidInput db 10, 10, "   ------------------ Error -------------------"
            db 10, "   Invalid input. Please enter a proper number!!!"
            db 10, "   --------------------------------------------$"

; Menu for purchasing items
purchaseItemMenu db 10,10,10
        db '   .------------------------------. ',10
        db '   |    21Cafe Menu Items         |',10
        db '   `------------------------------''',10
        db '    1. Java Chip Frappuccino   = 185 Pesos',10
        db '    2. Americano              = 190 Pesos',10
        db '    3. Iced Chai Latte        = 175 Pesos',10
        db '    4. Matcha Latte           = 160 Pesos',10
        db '    5. Blonde Vanilla         = 175 Pesos',10
        db '    6. Butter Croissant       = 150 Pesos',10
        db '    7. Back',10
        db '   ------------------------------',10
        db '   Which item would you like to purchase?: $'

; Prompt for quantity to purchase
purchaseItemInput db 10, "   How many would you like to purchase?: $"

; Message when purchase exceeds stock
purchaseExceed db 10, 10, "   Sorry, your purchase amount exceeds the current stock we have."
                db 10, "   Input a lower number !!!$"
				
; Ask user if they want to buy more
addToCartQuestion db 10, 10, "   Would you like to buy anything else?"
                   db 10, "   1. Yes"
                   db 10, "   2. No"
                   db 10, "   Enter your input: $"

; Header for total sales screen
totalSalesHeader db 10,10,10,"   .--------------------. ",10
                 db "   | Total Sales: Pesos | $"

; Inventory management UI strings
manageInventoryHeader db 10,10,10
        db '   .------------------------. ',10
        db '   |      Inventory         | ',10
        db '   `------------------------'' ',10
        db '   Stock: ',10
        db '   Java Chip Frappuccino   =  $'

americanoString db 10, "   Americano              =  $"
icedChaiString db 10, "   Iced Chai Latte        =  $"
matchaLatteString db 10, "   Matcha Latte           =  $"
blondeVanillaString db 10, "   Blonde Vanilla         =  $"
butterCroissantString db 10, "   Butter Croissant       =  $"

manageInventoryMenu db 10,10,"   1. Add Stock",10
        db "   2. Back",10
        db "   Enter your input: $"

addStockMenu db 10,10,10
        db '   .------------------------. ',10
        db '   |       Add Stock        | ',10
        db '   `------------------------'' ',10
        db '   1. Java Chip Frappuccino',10
        db '   2. Americano',10
        db '   3. Iced Chai Latte',10
        db '   4. Matcha Latte',10
        db '   5. Blonde Vanilla',10
        db '   6. Butter Croissant',10
        db 10, "   Input a number to add the stock: $"

addInput db 10, "   Enter the number to add: $"

; Cart display strings
cartInterfaceMenu db 10,10,10
        db '   .-----------------.',10
        db '   |      Cart       |',10
        db '   `-----------------''',10
        db '   Java Chip Frappuccino   =  $'

americanoCartString db 10, "   Americano              =  $"
icedChaiCartString db 10, "   Iced Chai Latte        =  $"
matchaLatteCartString db 10, "   Matcha Latte           =  $"
blondeVanillaCartString db 10, "   Blonde Vanilla         =  $"
butterCroissantCartString db 10, "   Butter Croissant       =  $"

cartOptions db 10,10, "   1. Checkout",10
             db "   2. Back",10
             db "   Enter your input: $"

cartTotal db 10, 10, "   Total(Pesos) = $"
checkoutSuccessMessage db 10, 10, "   Menu item(s) purchased successfully !!!$"
cartEmptyValidationMessage db 10, 10, "   Cart Is Empty!!!"
                         db 10, "   Checkout Failed. $"

anyKeyMsg db 10, "   Press any key to continue...$"

.code

; Clears the screen using BIOS interrupt
ClearScreen proc
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret
ClearScreen endp

; Waits for any key press from the user
WaitForKey proc
    mov ah, 09h
    mov dx, offset anyKeyMsg
    int 21h
    mov ah, 08h
    int 21h
    ret
WaitForKey endp

; Handles the login password check loop
PasswordCheck proc
PasswordLoop:
    call ClearScreen
    ; Print each login panel line
    mov ah, 09h
    mov dx, offset loginPanel1
    int 21h
    mov ah, 09h
    mov dx, offset loginPanel2
    int 21h
    mov ah, 09h
    mov dx, offset loginPanel3
    int 21h
    mov ah, 09h
    mov dx, offset loginPanel4
    int 21h
    ; Prompt for password input
    mov ah, 09h
    mov dx, offset askPassword
    int 21h
    mov passwordInput[0], 15     ; Set max input length
    mov ah, 0Ah
    mov dx, offset passwordInput
    int 21h                      ; DOS buffered input
    mov si, offset password
    mov di, offset passwordInput+2 ; Skip size bytes in DOS buffer
    mov cx, 8                    ; Password length
CompareLoop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne PasswordWrong            ; Not matching
    cmp al, 0
    je PasswordCorrect           ; End of string
    inc si
    inc di
    loop CompareLoop
    cmp byte ptr [di], 0Dh       ; Check if Enter was pressed
    je PasswordCorrect
PasswordWrong:
    mov ah, 09h
    mov dx, offset wrongPassword
    int 21h
    call WaitForKey
    jmp PasswordLoop             ; Retry input
PasswordCorrect:
    ret
PasswordCheck endp

; Menu for purchasing items
purchaseItemProc proc
purchaseMenuLoop:
    call ClearScreen
    mov ah, 09h
    mov dx, offset purchaseItemMenu
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne check2
    mov bx, offset javaChipStock
    mov si, offset javaChipPrice
    mov di, 0
    call BuyItem
    jmp purchaseMenuLoop
check2:
    cmp al, '2'
    jne check3
    mov bx, offset americanoStock
    mov si, offset americanoPrice
    mov di, 1
    call BuyItem
    jmp purchaseMenuLoop
check3:
    cmp al, '3'
    jne check4
    mov bx, offset icedChaiStock
    mov si, offset icedChaiPrice
    mov di, 2
    call BuyItem
    jmp purchaseMenuLoop
check4:
    cmp al, '4'
    jne check5
    mov bx, offset matchaLatteStock
    mov si, offset matchaLattePrice
    mov di, 3
    call BuyItem
    jmp purchaseMenuLoop
check5:
    cmp al, '5'
    jne check6
    mov bx, offset blondeVanillaStock
    mov si, offset blondeVanillaPrice
    mov di, 4
    call BuyItem
    jmp purchaseMenuLoop
check6:
    cmp al, '6'
    jne check7
    mov bx, offset butterCroissantStock
    mov si, offset butterCroissantPrice
    mov di, 5
    call BuyItem
    jmp purchaseMenuLoop
check7:
    cmp al, '7'
    jne purchaseItemInvalidInput
    ret                         ; Go back to main menu
purchaseItemInvalidInput:
    mov ah, 09h
    mov dx, offset invalidInput
    int 21h
    call WaitForKey
    jmp purchaseMenuLoop
purchaseItemProc endp

; Processes buying an item: subtracts from stock, adds to cart, updates total
; bx = address of stock, si = address of price, di = cart index
BuyItem proc
    mov ah, 09h
    mov dx, offset purchaseItemInput
    int 21h
    mov ah, 01h
    int 21h
    sub al, '0'                 ; Convert ASCII to integer
    mov bl, [bx]                ; Load current stock
    cmp bl, al
    jb NotEnoughStock           ; Not enough stock
    sub [bx], al                ; Update stock
    add cart[di], al            ; Add to cart
    mov bl, al                  ; Quantity
    mov ax, [si]                ; Load price
    mul bl                      ; ax = price * qty
    add total, ax               ; Add to running total
    mov ah, 09h
    mov dx, offset addToCartQuestion
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne BuyItemEnd              ; If not 1, return
    ret                         ; If 1, go back to menu
BuyItemEnd:
    ret
NotEnoughStock:
    mov ah, 09h
    mov dx, offset purchaseExceed
    int 21h
    call WaitForKey
    ret
BuyItem endp

; Handles adding stock to inventory
addStock proc
addStockMenuLoop:
    call ClearScreen
    mov ah, 09h
    mov dx, offset addStockMenu
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne addCheck2
    mov bx, offset javaChipStock
    call AddStockItem
    jmp addStockReturn
addCheck2:
    cmp al, '2'
    jne addCheck3
    mov bx, offset americanoStock
    call AddStockItem
    jmp addStockReturn
addCheck3:
    cmp al, '3'
    jne addCheck4
    mov bx, offset icedChaiStock
    call AddStockItem
    jmp addStockReturn
addCheck4:
    cmp al, '4'
    jne addCheck5
    mov bx, offset matchaLatteStock
    call AddStockItem
    jmp addStockReturn
addCheck5:
    cmp al, '5'
    jne addCheck6
    mov bx, offset blondeVanillaStock
    call AddStockItem
    jmp addStockReturn
addCheck6:
    cmp al, '6'
    jne addStockInvalidInput
    mov bx, offset butterCroissantStock
    call AddStockItem
    jmp addStockReturn
addStockInvalidInput:
    mov ah, 09h
    mov dx, offset invalidInput
    int 21h
    call WaitForKey
    jmp addStockMenuLoop
addStockReturn:
    ret
addStock endp

; Adds input number to a given stock variable (bx points to it)
AddStockItem proc
    mov ah, 09h
    mov dx, offset addInput
    int 21h
    mov ah, 01h
    int 21h
    sub al, '0'
    add [bx], al
    ret
AddStockItem endp

; Displays AX as an integer (used for stock and sales)
; If stock is <= 5, uses a different color for "low stock"
displayInteger proc
    cmp ax, 5
    jle lowStock
    mov cx, 0
    mov bx, 10
convertToString:
    mov dx, 0
    div bx
    push ax
    add dl, '0'
    pop ax
    push dx
    inc cx
    cmp ax, 0
    jnz convertToString
    mov ah, 02h
displayString:
    pop dx
    int 21h
    dec cx
    jnz displayString
    ret
lowStock:
    mov ah, 09h
    add ax, '0'
    mov bh, 0
    mov bl, 4Fh
    mov cx, 1
    int 10h
    ret
displayInteger endp

; Handles cart interface and checkout logic
checkoutProc proc
printCartLoop:
    call ClearScreen
    ; Display cart quantities for each item
    mov ah, 09h
    mov dx, offset cartInterfaceMenu
    int 21h
    mov al, cart[0]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, offset americanoCartString
    int 21h
    mov al, cart[1]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, offset icedChaiCartString
    int 21h
    mov al, cart[2]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, offset matchaLatteCartString
    int 21h
    mov al, cart[3]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, offset blondeVanillaCartString
    int 21h
    mov al, cart[4]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    mov ah, 09h
    mov dx, offset butterCroissantCartString
    int 21h
    mov al, cart[5]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    ; Display cart total
    mov ah, 09h
    mov dx, offset cartTotal
    int 21h
    mov ax, total
    call displayInteger
    mov ah, 09h
    mov dx, offset cartOptions
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne cartCheck2
    cmp total, 0
    jne cartNotEmpty
    ; If cart is empty, display error
    mov ah, 09h
    mov dx, offset cartEmptyValidationMessage
    int 21h
    call WaitForKey
    jmp cartReturn
cartNotEmpty:
    ; Add to total sales and clear cart
    mov ax, [total]
    add ax, [totalSales]
    mov [totalSales], ax
    mov total, 0
    mov cart[0], 0
    mov cart[1], 0
    mov cart[2], 0
    mov cart[3], 0
    mov cart[4], 0
    mov cart[5], 0
    mov ah, 09h
    mov dx, offset checkoutSuccessMessage
    int 21h
    call WaitForKey
    jmp cartReturn
cartCheck2:
    cmp al, '2'
    jne cartInputError
    jmp cartReturn
cartInputError:
    mov ah, 09h
    mov dx, offset invalidInput
    int 21h
    call WaitForKey
    jmp printCartLoop
cartReturn:
    ret
checkoutProc endp

; Main program entry point and menu logic
Main proc
    mov ax, @data
    mov ds, ax
    call PasswordCheck
    mov ah, 09h
    mov dx, offset greetingMessage
    int 21h
    jmp MainInterface
MainInterface:
    call ClearScreen
    mov ah, 09h
    mov dx, offset mainMenu
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne mainCheck2
    call purchaseItemProc
    jmp MainInterface
mainCheck2:
    cmp al, '2'
    jne mainCheck3
    call ClearScreen
    mov ah, 09h
    mov dx, offset totalSalesHeader
    int 21h
    mov ax, totalSales
    call displayInteger
    call WaitForKey
    jmp MainInterface
mainCheck3:
    cmp al, '3'
    jne mainCheck4
    call ClearScreen
    mov ah, 09h
    mov dx, offset manageInventoryHeader
    int 21h
    mov ax, javaChipStock
    call displayInteger
    mov ah, 09h
    mov dx, offset americanoString
    int 21h
    mov ax, americanoStock
    call displayInteger
    mov ah, 09h
    mov dx, offset icedChaiString
    int 21h
    mov ax, icedChaiStock
    call displayInteger
    mov ah, 09h
    mov dx, offset matchaLatteString
    int 21h
    mov ax, matchaLatteStock
    call displayInteger
    mov ah, 09h
    mov dx, offset blondeVanillaString
    int 21h
    mov ax, blondeVanillaStock
    call displayInteger
    mov ah, 09h
    mov dx, offset butterCroissantString
    int 21h
    mov ax, butterCroissantStock
    call displayInteger
    mov ah, 09h
    mov dx, offset manageInventoryMenu
    int 21h
    mov ah, 01h
    int 21h
    cmp al, '1'
    jne manageCheck2
    call addStock
    jmp MainInterface
manageCheck2:
    cmp al, '2'
    jne mainError
    jmp MainInterface
mainCheck4:
    cmp al, '4'
    jne mainCheck5
    call checkoutProc
    jmp MainInterface
mainCheck5:
    cmp al, '5'
    jne mainError
    mov ah, 4ch
    int 21h                     ; Exit program
mainError:
    mov ah, 09h
    mov dx, offset invalidInput
    int 21h
    call WaitForKey
    jmp MainInterface

main endp
end main