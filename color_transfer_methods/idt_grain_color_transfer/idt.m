function final_IR_idt_regrain=idt(I1, I2, M1, M2)

im1=(uint8(I1).*uint8(M1));
im2=(uint8(I2).*uint8(M2));
im1=double(im1)/255; im2=double(im2)/255;
fg = uint8(M1); bg = 1 - fg;
IR_idt = idt_transfer(im1,im2,M1,M2,10);
IR_idt_regrain = regrain(im1,IR_idt); 
IR_idt_regrain=uint8(IR_idt_regrain*255);
final_IR_idt_regrain=IR_idt_regrain.*fg+uint8(I1).*bg;