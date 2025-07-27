import tkinter as tk
from tkinter import messagebox

class Calculator(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Calculator")
        self.geometry("400x600")

        self.expression = ""
        self.input_text = tk.StringVar()

        self.create_widgets()

    def create_widgets(self):
        input_frame = tk.Frame(self, height=100, bd=0, highlightbackground="black", highlightcolor="black", highlightthickness=2)
        input_frame.pack(side=tk.TOP)

        input_field = tk.Entry(input_frame, font=('arial', 18, 'bold'), textvariable=self.input_text, width=50, bg="#eee", bd=0, justify=tk.RIGHT)
        input_field.grid(row=0, column=0)
        input_field.pack(ipady=10)

        btns_frame = tk.Frame(self, bg="grey")
        btns_frame.pack()

        buttons = [
            '7', '8', '9', 'C',
            '4', '5', '6', '/',
            '1', '2', '3', '*',
            '0', '.', '=', '+',
            '-', '(', ')'
        ]

        row = 0
        col = 0

        for button in buttons:
            action = lambda x=button: self.on_button_click(x)
            tk.Button(btns_frame, text=button, width=10, height=3, bd=0, bg="#fff", cursor="hand2", command=action).grid(row=row, column=col, padx=1, pady=1)
            col += 1
            if col > 3:
                col = 0
                row += 1

    def on_button_click(self, char):
        if char == 'C':
            self.expression = ""
        elif char == '=':
            try:
                self.expression = str(eval(self.expression))
            except:
                messagebox.showerror("Error", "Invalid Input")
                self.expression = ""
        else:
            self.expression += str(char)
        self.input_text.set(self.expression)

if __name__ == "__main__":
    app = Calculator()
    app.mainloop()