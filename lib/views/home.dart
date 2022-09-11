import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_clone/helperfunctions/sharepref_helper.dart';
import 'package:messenger_clone/services/auth.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:messenger_clone/views/chatscreen.dart';
import 'package:messenger_clone/views/signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  Stream<QuerySnapshot>? usersStream, chatRoomsStream;
  late String myName, myProfilePic, myUserName, myEmail;

  TextEditingController searchUserNameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUsername(searchUserNameEditingController.text);
    setState(() {});
  }

  // Widget chatRoomListTile(String profilePicUrl, String lastMessage) {
  //   return Row(
  //     children: [
  //       Image.network(profilePicUrl),
  //       Column(
  //         children: [Text(""), Text(lastMessage)],
  //       )
  //     ],
  //   );
  // }

  Widget chatRoomsList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return ChatRoomListTile(
                        ds['lastMessage'], ds.id, myUserName);
                    // Text(ds.id.replaceAll(myUserName, "").replaceAll("_", ""));
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget searchListUserTile(
      {required String profileUrl, name, email, username}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(email),
            ],
          )
        ],
      ),
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  Widget searchUsersList() {
    return StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  // scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"],
                    )
                        // height: 30,
                        // width: 30,
                        ;
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messenger"),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((f) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const SignIn()));
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(
                Icons.exit_to_app,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUserNameEditingController.text = "";
                          setState(() {});
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUserNameEditingController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'username',
                          ),
                        )),
                        GestureDetector(
                            onTap: () {
                              if (searchUserNameEditingController.text != "") {
                                onSearchButtonClick();
                              }
                            },
                            child: const Icon(Icons.search)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList(),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  // const ChatRoomListTile({Key? key}) : super(key: key);

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print("something ${querySnapshot.docs[0].id}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return profilePicUrl != ""
    // ?
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profilePicUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 3,
              ),
              Text(widget.lastMessage)
            ],
          )
        ],
      ),
    );
    // : Container();
  }
}
