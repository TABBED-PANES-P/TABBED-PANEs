package org.example;

import javax.swing.*;
import java.awt.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;


public class TappedPaneIntegrationTest {
    @Test
    public void testFullPanelIntegration() {
        TappedPane tappedPane = new TappedPane();
        //panel 1
        tappedPane.HomePanel();

        assertNotNull(tappedPane.Panel1);
        assertEquals(1, tappedPane.Panel1.getComponentCount());

        //Panel 2
        tappedPane.FormPanel();

        assertNotNull(tappedPane.Panel2);
        assertNotNull(tappedPane.nameField);
        assertNotNull(tappedPane.EmailField);
        assertNotNull(tappedPane.SubscribeBox);
        assertNotNull(tappedPane.SubmitBtn);
        assertNotNull(tappedPane.HomeBtn);

        assertTrue(tappedPane.Panel2.getLayout() instanceof GridLayout);
        GridLayout layout = (GridLayout) tappedPane.Panel2.getLayout();
        assertEquals(4, layout.getRows());
        assertEquals(2, layout.getColumns());

        tappedPane.nameField.setText("Ali");
        tappedPane.EmailField.setText("Ali@gmail.com");
        tappedPane.SubscribeBox.setSelected(true);

        assertEquals("Ali", tappedPane.nameField.getText());
        assertEquals("Ali@gmail.com", tappedPane.EmailField.getText());
        assertTrue(tappedPane.SubscribeBox.isSelected());

        //Panel 3
        tappedPane.ListAddPanel();

        assertNotNull(tappedPane.Panel3);
        assertEquals(3, tappedPane.Panel3.getComponentCount());

        assertTrue(tappedPane.Panel3.getComponent(0) instanceof JScrollPane);
        JPanel inputPanel = (JPanel) tappedPane.Panel3.getComponent(1);
        assertTrue(inputPanel.getComponent(0) instanceof JTextField);
        assertTrue(inputPanel.getComponent(1) instanceof JButton);
        JPanel buttonPanel = (JPanel) tappedPane.Panel3.getComponent(2);
        assertTrue(buttonPanel.getComponent(0) instanceof JButton);
        assertTrue(buttonPanel.getComponent(1) instanceof JButton);

        //Panel 4
        tappedPane.ButtonInteractionPanel();

        assertNotNull(tappedPane.Panel4);
        assertEquals(3, tappedPane.Panel4.getComponentCount());

        assertTrue(tappedPane.Panel4.getComponent(0) instanceof JLabel);
        assertTrue(tappedPane.Panel4.getComponent(1) instanceof JButton);
        assertTrue(tappedPane.Panel4.getComponent(2) instanceof JButton);

        //Panel 5
        tappedPane.AboutInfoPanel();

        assertNotNull(tappedPane.Panel5);
        assertEquals(3, tappedPane.Panel5.getComponentCount());
    }

}
