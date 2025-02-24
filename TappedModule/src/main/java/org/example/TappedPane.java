package org.example;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
public class TappedPane {

    JFrame frame;
    JPanel Panel1, Panel2, Panel3, Panel4, Panel5;
    JTabbedPane TabbedPane;
    JLabel name, Email, Subscribe, countLabel;
    JTextField nameField, EmailField, taskField;
    JCheckBox SubscribeBox;
    JButton SubmitBtn, HomeBtn, incrementButton, resetButton, clearListBtn, addTaskBtn;
    JTextArea About;

    DefaultListModel<String> listModel;
    JList<String> itemList;
    JScrollPane scrollPane;

    public TappedPane() {
        frame = new JFrame("TappedPane");
        frame.setSize(530, 400);
        frame.setLocationRelativeTo(null);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        TabbedPane = new JTabbedPane();

        HomePanel();
        FormPanel();
        ListAddPanel();
        ButtonInteractionPanel();
        AboutInfoPanel();

        TabbedPane.addTab("Home", Panel1);
        TabbedPane.addTab("Forms", Panel2);
        TabbedPane.addTab("Lists", Panel3);
        TabbedPane.addTab("Buttons", Panel4);
        TabbedPane.addTab("Information", Panel5);

        frame.add(TabbedPane);
        frame.setVisible(true);
    }

    void HomePanel() {
        Panel1 = new JPanel();
        Panel1.add(new JLabel("Home Page"));
    }

    void FormPanel() {
        Panel2 = new JPanel();
        Panel2.setLayout(new GridLayout(4, 2));

        name = new JLabel("Name: ");
        nameField = new JTextField();
        Email = new JLabel("Email: ");
        EmailField = new JTextField();
        Subscribe = new JLabel("Subscribe: ");
        SubscribeBox = new JCheckBox();
        SubmitBtn = new JButton("Submit");

        SubmitBtn.addActionListener(e -> {
            String name = nameField.getText();
            String email = EmailField.getText();
            boolean isSubscribed = SubscribeBox.isSelected();
            if (name.isEmpty() || email.isEmpty()) {
                JOptionPane.showMessageDialog(frame, "Please fill in all the Inputs", "Warning", JOptionPane.WARNING_MESSAGE);
                return;
            }

            JOptionPane.showMessageDialog(frame, "Name: " + name + "\nEmail: " + email + "\nSubscribed: " + isSubscribed);
        });

        HomeBtn = new JButton("Go to Home");
        HomeBtn.addActionListener(e -> TabbedPane.setSelectedIndex(0));

        Panel2.add(name);
        Panel2.add(nameField);
        Panel2.add(Email);
        Panel2.add(EmailField);
        Panel2.add(Subscribe);
        Panel2.add(SubscribeBox);
        Panel2.add(SubmitBtn);
        Panel2.add(HomeBtn);
    }

    void ListAddPanel() {
        Panel3 = new JPanel();
        Panel3.setLayout(new BorderLayout());

        listModel = new DefaultListModel<>();
        itemList = new JList<>(listModel);
        scrollPane = new JScrollPane(itemList);

        taskField = new JTextField();
        addTaskBtn = new JButton("Add Task");
        clearListBtn = new JButton("Clear List");

        addTaskBtn.addActionListener(e -> {
            String task = taskField.getText();
            if (!task.isEmpty()) {
                listModel.addElement(task);
                taskField.setText("");
            } else {
                JOptionPane.showMessageDialog(null, "Please enter a task.");
            }
        });

        clearListBtn.addActionListener(e -> listModel.clear());

        JPanel inputPanel = new JPanel();
        inputPanel.setLayout(new BorderLayout());
        inputPanel.add(taskField, BorderLayout.CENTER);
        inputPanel.add(addTaskBtn, BorderLayout.EAST);

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(clearListBtn);
        buttonPanel.add(HomeBtn);

        Panel3.add(scrollPane, BorderLayout.CENTER);
        Panel3.add(inputPanel, BorderLayout.NORTH);
        Panel3.add(buttonPanel, BorderLayout.SOUTH);
    }

    void ButtonInteractionPanel() {
        Panel4 = new JPanel();

        countLabel = new JLabel("Count: 0");
        incrementButton = new JButton("+1");
        resetButton = new JButton("Reset");

        Panel4.add(countLabel);
        Panel4.add(incrementButton);
        Panel4.add(resetButton);

        int[] count = {0};

        incrementButton.addActionListener(e -> {
            count[0]++;
            countLabel.setText("Count: " + count[0]);
        });

        resetButton.addActionListener(e -> {
            count[0] = 0;
            countLabel.setText("Count: 0");
        });
    }

    void AboutInfoPanel() {
        Panel5 = new JPanel();
        Panel5.setLayout(new BorderLayout());
        Panel5.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JLabel titleLabel = new JLabel("<html><h2>About Us</h2></html>");
        titleLabel.setHorizontalAlignment(SwingConstants.CENTER);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 24));
        Panel5.add(titleLabel, BorderLayout.NORTH);

        About = new JTextArea("We are a team of passionate developers who created this app to make life easier...\n\n"
                + "Our app helps users to manage their tasks and stay organized.");

        About.setFont(new Font("Arial", Font.PLAIN, 14));
        Panel5.add(About, BorderLayout.CENTER);

        JPanel contactInfoPanel = new JPanel();
        contactInfoPanel.setLayout(new GridLayout(3, 1));

        JLabel emailLabel = new JLabel("Email: Mustaphamouliid@gmail.com");
        JLabel phoneLabel = new JLabel("Phone: +252615988376");
        JLabel websiteLabel = new JLabel("Website: www.IUEA.com");

        contactInfoPanel.add(emailLabel);
        contactInfoPanel.add(phoneLabel);
        contactInfoPanel.add(websiteLabel);

        Panel5.add(contactInfoPanel, BorderLayout.SOUTH);
        Panel5.setBackground(Color.WHITE);
    }

}
