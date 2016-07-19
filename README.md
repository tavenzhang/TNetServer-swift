 <h1>TNetServer-swift</h1>
 
 本项目对CocoaAsyncSocket, ProtocolBuffers-Swift 进行了简单的的封装和处理，使得ios socket通信更方便使用 <br/>
    通过继承覆写 TSockerGCD中的 
    <ul>
    func readMsgHead(data: NSMutableData) -> Int; <br/>
    func readMsgBody(data: NSMutableData) -> Bool;<br/>
    func sendHeartMsg() -> Void;<br/>
    func sendMessage(msgData: AnyObject?) -> Void;<br/>
    </ul>
 
    可以支持各种基于ios Asysocket的数据通信。 默认实现amf3 与 protobuf 方式。
    
  同时对   Socket.IO-Client-Swift, SwiftWebSocket  也进行了简单封装，并写了对应的测试demo
  
