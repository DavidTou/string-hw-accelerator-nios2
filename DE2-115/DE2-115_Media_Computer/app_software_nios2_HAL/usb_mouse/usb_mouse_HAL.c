#include "altera_up_avalon_usb.h"
#include "altera_up_avalon_usb_mouse_driver.h"
#include "altera_up_avalon_usb_high_level_driver.h"
#include "altera_up_avalon_usb_low_level_driver.h"
#include "altera_up_avalon_usb_regs.h"
#include "altera_up_avalon_parallel_port.h"

/********************************************************************************
 * This program demonstrates use of the USB in the computer
* It performs the following: 
*    1. detects if a USB mouse device is present
*    2. displays the x axis value of the mouse on LEDRs
*    3. displays the y axis value of the mouse on LEDGs
*    4. displays the button status on HEXs
********************************************************************************/

unsigned int usb_play_mouse(alt_up_usb_dev * usb_device, int addr, int port);

int main(void){
	// 1.Open the USB device
    alt_up_usb_dev * usb_device;
    usb_device = alt_up_usb_open_dev("/dev/USB");	
    if (usb_device != NULL) {
        //printf("usb_device->base %08x, please check if this matches the USB's base address in Qsys\n", usb_device->base);
        unsigned int mycode;
        int port = -1;
        int addr = -1;
        int config = -1;
        int HID = -1; //Human Interface Device Descriptor number.
        while (1) {
            port = -1;
            addr = -1;

            // 2. Set up the USB and get the connected port number and its address
            HID = alt_up_usb_setup(usb_device, &addr, &port);

            if (port != -1 && HID == 0x0209) {
                // 3. After confirming that the device is connected is a mouse, the host must choose a configuration on the device
                config = 1;
                mycode = alt_up_usb_set_config(usb_device, addr, port, config);
                if (mycode == 0) {
                    // 4. Set up and play mouse
                    usb_play_mouse(usb_device, addr, port);
                }
            }
        }
    }else {
        printf("Error: could not open USB device\n");
    }	
	return 0;
}

unsigned int usb_play_mouse(alt_up_usb_dev * usb_device, int addr, int port) {

    printf("ISP1362 USB Mouse Demo.....\n");

    alt_up_usb_mouse_setup(usb_device, addr, port);

    alt_up_usb_mouse_packet usb_mouse_packet;

    usb_mouse_packet.x_movement = 0;
    usb_mouse_packet.y_movement = 0;
    usb_mouse_packet.buttons = 0;

    unsigned int pX = 320, pY = 240;

    do {

        pX = pX + usb_mouse_packet.x_movement;
        pY = pY + usb_mouse_packet.y_movement;

        if (pX > 639) {
            pX = 639;
        }
        if (pX < 0) {
            pX = 0;
        }
        if (pY > 479) {
            pY = 479;
        }
        if (pY < 0) {
            pY = 0;
        }

        alt_up_parallel_port_dev * Green_LEDs_dev;
        alt_up_parallel_port_dev * Red_LEDs_dev;
        alt_up_parallel_port_dev * HEX3_HEX0_dev;

        Green_LEDs_dev = alt_up_parallel_port_open_dev("/dev/Green_LEDs");
        Red_LEDs_dev = alt_up_parallel_port_open_dev("/dev/Red_LEDs");
        HEX3_HEX0_dev = alt_up_parallel_port_open_dev("/dev/HEX3_HEX0");

        alt_up_parallel_port_write_data(Red_LEDs_dev, pX);
        alt_up_parallel_port_write_data(Green_LEDs_dev, pY);

        if ((usb_mouse_packet.buttons & 0x1) == 1) { //left button 
            alt_up_parallel_port_write_data(HEX3_HEX0_dev, 0x3f0000);
        }
        if (((usb_mouse_packet.buttons & 0x2) >> 1) == 1) { //right button
            alt_up_parallel_port_write_data(HEX3_HEX0_dev, 0x3f);
        }
        if (((usb_mouse_packet.buttons & 0x4) >> 2) == 1) { //center button
            alt_up_parallel_port_write_data(HEX3_HEX0_dev, 0x3f00);
        }

        usb_mouse_packet.x_movement = 0;
        usb_mouse_packet.y_movement = 0;
        usb_mouse_packet.buttons = 0;

        // Polling and get the data from the mouse	
    } while (alt_up_usb_retrieve_mouse_packet(usb_device, &usb_mouse_packet) != ALT_UP_USB_MOUSE_NOT_CONNECTED);
    printf("Mouse Not Detected\n");
    return 0;
}

