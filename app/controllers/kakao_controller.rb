require 'rubygems'
require 'rest-client'
require 'cgi'
require 'nokogiri'
require 'open-uri'
require 'uri'


class String
  def numeric?
    return true if self =~ /\A\d+\Z/
    true if Float(self) rescue false
  end
end 

class KakaoController < ApplicationController

    def keyboard #처음에 들어갔을 때 밑에 뜨는 키보드
    @msg = {
      type: "buttons",
      buttons: ["시작하기"]
    }
    render json: @msg
    end
  
  @@num = 0
  
  def message
    @user_msg = params[:content]
    if @user_msg == "시작하기" or @user_msg == "다시 시작하기"
      
      @msg = {
          message: {
            text: "안녕하세요(하트뿅)\n서울시 버스와 지하철 운행 정보를 드립니다~\n\n1.버스 실시간 도착정보\n2.지하철 실시간 도착정보\n3.즐겨찾기\n\n이용하고 싶은 서비스를 선택해주세요!"
          },keyboard:{
            type: "text"
          }
        }
        
        render json: @msg
    else
        @info = params[:content]
        @key = params[:user_key]
        @user = User.find_or_create_by(key: @key)
        
        if @info == "1" or @info == "1번" and @@num != 3
            @@num = 1
             @msg = {
          message: {
            text: "버스번호와 버스정류장명 또는 ID를 입력해주세요\n(예: 7737/14015 또는 7737/홍대입구역)"
          },keyboard:{
            type: "text"
          }
        }
        
        render json: @msg
        else if @info == "2" or @info =="2번" and @@num != 3
            @@num = 2
             @msg = {
          message: {
            text: "호선과 지하철역 명을 입력해주세요\n(예: 2호선>건대입구)"
          },keyboard:{
            type: "text"
          }
        }
        
        render json: @msg
        else if @info == "3" or @info == "3번" and @@num != 3
            @@num = 3
            if @user.one == nil and @user.two == nil and @user.three == nil and @user.four == nil and @user.five ==nil
                @@num = 0
                 @msg = {
                      message: {
                      text: "저장된 즐겨찾기가 없습니다(눈물)\n버스나 지하철 도착정보를 검색해서 즐겨찾기를 추가해보세요!"
                     },keyboard:{
                          type: "buttons",
                          buttons: ["시작하기"]
                     }
                   }
        
                 render json: @msg
            else
                @save = ""
                count = 0
                if @user.one != nil
                    count = count + 1
                    @save = @save + "#{count}.#{@user.one}\n"
                end
                if @user.two != nil
                    count = count + 1
                    @save = @save + "#{count}.#{@user.two}\n"
                end
                if @user.three != nil
                    count = count + 1
                    @save = @save + "#{count}.#{@user.three}\n"
                end
                if @user.four != nil
                    count = count + 1
                    @save = @save + "#{count}.#{@user.four}\n"
                end
                if @user.five != nil
                    count = count + 1
                    @save = @save + "#{count}.#{@user.five}\n"
                end
                  
                  
                @text1 = "<저장된 즐겨찾기 목록>\n"
                @text2 = "검색하고 싶은 노선의 번호를 입력하세요"
                @text = @text1 + @save + "\n"+@text2
                 @msg = {
                      message: {
                      text: @text
                     },keyboard:{
                          type: "text"
                          
                     }
                   }
        
                 render json: @msg
                
            end
        else if @info == "즐겨찾기에 추가"
            
            if @user.one == nil
                @user.one = @@query
                @user.save
            elsif @user.two == nil
                @user.two = @@query
                @user.save
            elsif @user.three == nil
                @user.three = @@query
                @user.save
            elsif @user.four == nil
                @user.four = @@query
                @user.save
            else 
                @user.five = @@query
                @user.save
            end
            
             @msg = {
                      message: {
                      text: "즐겨찾기에 추가되었습니다!"
                     },keyboard:{
                          type: "buttons",
                          buttons: ["다시 시작하기"]
                          
                     }
                   }
        
                 render json: @msg
        else if @info == "즐겨찾기 삭제"
            if @@delete == "1"
                if @user.one == nil
                    @user.two = nil
                end
                @user.one = nil
                if @user.one == nil and @user.two == nil
                    @user.three = nil
                end
                
            elsif @@delete == "2"
                if @user.two == nil
                    @user.three = nil
                end
                @user.two = nil
            elsif @@delete == "3"
                if @user.three == nil
                    @user.four = nil
                end
                @user.three = nil
            elsif @@delete == "4"
                if @user.four == nil
                    @user.five = nil
                end
                @user.four = nil
            else
                @user.five=nil
            end
            @user.save
            
             @msg = {
                      message: {
                      text: "즐겨찾기에서 삭제되었습니다!"
                     },keyboard:{
                          type: "buttons",
                          buttons: ["다시 시작하기"]
                          
                     }
                   }
        
                 render json: @msg
                
        else if @@num == 3
            @@num = 0
            
            if @info == "1"
                @thing =@user.one
                if @thing == nil
                    @thing = @user.two
                end
                if @user.two == nil and @user.one == nil
                    @thing = @user.three
                end
            elsif @info == "2"
                @thing = @user.two
                if @thing == nil or @user.one == nil
                    @thing = @user.three
                end
                if @user.three == nil and @user.two == nil
                    @thing = @user.four
                end
            elsif @info == "3"
                @thing = @user.three
                if @thing == nil and @user.one == nil
                    @thing = @user.five
                elsif @thing == nil or @user.one == nil or @user.two == nil
                    @thing = @user.four
                end
            elsif @info == "4"
                @thing = @user.four
                if @thing == nil or @user.one ==nil or @user.two == nil or @user.three == nil
                    @thing = @user.five
                end
            else
                @thing = @user.five
            end
            @@delete = @info
            if @thing.include? "/"
                 arr = @thing.split("/")
           @num = arr[0]
           @bus_id = arr[1]
        #   n=0
        #     for i in 0..@num.length
            
        #     if @num[i..i].numeric? == false
        #       n = n+1
        #     end
        #     end
        #     h= @num[(n-1)..@num.length]
           h = URI.encode(@num)
           url1 = "http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList?serviceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&strSrch=#{h}"
           
            doc1 = Nokogiri::XML(open(url1))
            @buses = doc1.xpath('//itemList').map do |i|
             { :busRouteId => i.xpath('busRouteId').inner_text,
               :busRouteNm => i.xpath('busRouteNm').inner_text
        }
        end
        
            if @buses.count == 1
             id = @buses.first[:busRouteId]
            else
              
            @buses.each do |b|
                if b[:busRouteNm] == @num
                    id = b[:busRouteId]
                    break
                end
            end
            end
            
            url2 = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute?ServiceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&busRouteId=#{id}"
            doc2 = Nokogiri::XML(open(url2))
            @seqs = doc2.xpath('//itemList').map do |i|
                { :stationNm => i.xpath('stationNm').inner_text,
                  :stationNo => i.xpath('stationNo').inner_text,
                  :seq => i.xpath('seq').inner_text,
                  :gpsX => i.xpath('gpsX').inner_text,
                  :gpsY => i.xpath('gpsY').inner_text
                }
            end
            
            c=0
            @seqs.each do |o|
                if o[:stationNm] == @bus_id or o[:stationNo] == @bus_id
                    c=c+1
                    @@x = o[:gpsX]
                    @@y = o[:gpsY]
                    
                end
            end
            puts c
            
            # if c==1
            #     @seqs.each do |o|
            #         if o[:stationNm] = @bus_id or o[:stationNo] == @bus_id
            #             seq1 = o[:seq]
            #             seq2 = seq1.to_i +1
            #         end
            #     end
            #     @seqs.each do |o|
            #         if o[:seq] == seq2.to_s
            #             nextS = o[:stationNm]
            #         end
            #     end
            # else
            seq = [0,0,0]
            nextS = [0,0,0]
            i=0
            j=0
                @seqs.each do |o|
                    if o[:stationNm] == @bus_id or o[:stationNo] == @bus_id
                        
                        seq_imsi = o[:seq]
                        seq[i] = seq_imsi.to_i + 1
                        i = i+1
                    end
                    
                end
                
                 @seqs.each do |o|
                    if o[:seq] == seq[j].to_s
                        nextS[j] = o[:stationNm]
                        j = j+1
                    end
                end
                
                
            # end
            
            url = "http://ws.bus.go.kr/api/rest/arrive/getArrInfoByRouteAll?serviceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&busRouteId=#{id}"
       
        doc = Nokogiri::XML(open(url))
        @items = doc.xpath('//itemList').map do |i|
         { :stNm => i.xpath('stNm').inner_text,
              :arsId => i.xpath('arsId').inner_text,
             :busRouteId => i.xpath('busRouteId').inner_text,
             :rtNm => i.xpath('rtNm').inner_text,
              :arrmsg1 => i.xpath('arrmsg1').inner_text,
              :arrmsg2 => i.xpath('arrmsg2').inner_text,
              :busType1 => i.xpath('busType1').inner_text,
              :busType2 => i.xpath('busType2').inner_text
            }
        end
        iter = 0
        @items.each do |o|
        if o[:arsId] == @bus_id or o[:stNm] == @bus_id
            iter = iter + 1
            if iter == 1
            @text = "(별)정류소명 : #{o[:stNm]}(#{o[:arsId]})\n((#{nextS[0]}방면))\n(별)버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
            else
                @text1 = "\n\n(별)정류소명 : #{o[:stNm]}(#{o[:arsId]})\n((#{nextS[1]}방면))\n(별)버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
            end
            
           
          if o[:busType1]=='0'
              bType1 = '일반버스'
          elsif o[:busType1] == '1'
              bType1 = '저상버스'
          else
              bType1 = '굴절버스'
          end
           
            if o[:busType2]=='0'
              bType2 = '일반버스'
          elsif o[:busType2] == '1'
              bType2 = '저상버스'
          else
              bType2 = '굴절버스'
            end
           
          @text2 = "첫번째 도착 차량 유형 : #{bType1}\n두번째 도착 차량 유형 : #{bType2}"
         
            
        end
      end
      if iter == 0 #버스정류장을 잘못 입력하면
         @text3 = "버스번호와 정류장을 (별)정확히(별) 다시 입력해주세요(찡긋)"
       
      end
      
      if iter == 1
          @text3 = @text
      elsif iter == 2
          @text3 = @text + @text1
      end
      
      if iter == 0
       @msg = {
              message: {
                text:  @text3
              },keyboard:{
                type: "text"
         
              }
            }
            
            render json: @msg
        else
            @msg = {
              message: {
                text:  @text3,
                message_button: {
                label: "정류장 위치 확인하기",
                url: "http://map.daum.net/link/map/#{@@y},#{@@x}"
              }
             },keyboard:{
                type: "buttons",
                buttons: ["즐겨찾기 삭제","다시 시작하기"]
              }
            }
            
            render json: @msg
        end
    else
        arr = @thing.split(">")
         subLine = arr[0]                     #호선
         subStation = arr[1]                  #지하철역
         
        
         
         @inSubLine=URI.encode(subLine)
         @inSubStation=URI.encode(subStation)
         
         #지하철 호선 정보 xml 파일
         url = "http://swopenapi.seoul.go.kr/api/subway/55474c6a7773647231313348614b5479/xml/subwayLine/0/5/#{@inSubLine}"
          doc = Nokogiri::XML(open(url))
            @subway = doc.xpath('//row').map do |i|
             { :subwayId => i.xpath('subwayId').inner_text
        }
        end
        
        subId= @subway.first[:subwayId]
        url1 = "http://swopenapi.seoul.go.kr/api/subway/4865595641736472363266475a7344/xml/realtimeStationArrival/0/20/#{@inSubStation}"
        doc1 = Nokogiri::XML(open(url1))
        @items = doc1.xpath('//row').map do |i|
            {
                :subwayId => i.xpath('subwayId').inner_text,
                :trainLineNm => i.xpath('trainLineNm').inner_text,
                :arvlMsg2 => i.xpath('arvlMsg2').inner_text
            }
        end
         iter = 0
        @items.each do |o|
            if o[:subwayId] == subId 
                iter = iter + 1
                if iter == 1
                @text = "(별) 노선 : #{subLine}\n(별) 역명 : #{subStation}역\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter ==2
                    @text1 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 3
                    @text2 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 4
                    @text3 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 5
                    @text4 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                else
                    @text5 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                end
            end
        end
        
        
       
       if iter == 0 #버스정류장을 잘못 입력하면
         @text6 = "지하철호선와 역명을 (별)정확히(별) 다시 입력해주세요(찡긋)\n(강남역 -> 강남으로 입력)"
     elsif iter == 1
          @text6 = @text
      elsif iter == 2
          @text6 = @text + @text1
      elsif iter == 3
          @text6 = @text +@text1 +@text2
     elsif iter == 4
          @text6 = @text +@text1 +@text2+@text3
     elsif iter == 5
          @text6 = @text +@text1 +@text2+@text3+@text4
      else
          @text6 = @text +@text1 +@text2+@text3+@text4+@text5
          
      end
      
      if iter == 0
       @msg = {
              message: {
                text:  @text6
              },keyboard:{
                type: "text"
         
              }
            }
            
            render json: @msg
        else
            @code = URI.encode("강남역")
            @msg = {
              message: {
                text:  @text6,
                message_button: {
                    label: "지하철역 위치 확인하기",
                    url: "http://map.daum.net/link/search/#{@inSubStation}"
                }
              },keyboard:{
                type: "buttons",
          buttons: ["즐겨찾기 삭제","다시 시작하기"]
              }
            }
            
            render json: @msg
        end
        
        
    
  
    end
                
                
        else if @info.include? "/" 
            @@query = @info
           arr = @info.split("/")
           @num = arr[0]
           @bus_id = arr[1]
        #   n=0
        #     for i in 0..@num.length
            
        #     if @num[i..i].numeric? == false
        #       n = n+1
        #     end
        #     end
        #     h= @num[(n-1)..@num.length]
           h = URI.encode(@num)
           url1 = "http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList?serviceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&strSrch=#{h}"
           
            doc1 = Nokogiri::XML(open(url1))
            @buses = doc1.xpath('//itemList').map do |i|
             { :busRouteId => i.xpath('busRouteId').inner_text,
               :busRouteNm => i.xpath('busRouteNm').inner_text
        }
        end
        
            if @buses.count == 1
             id = @buses.first[:busRouteId]
            else
              
            @buses.each do |b|
                if b[:busRouteNm] == @num
                    id = b[:busRouteId]
                    break
                end
            end
            end
            
            url2 = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute?ServiceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&busRouteId=#{id}"
            doc2 = Nokogiri::XML(open(url2))
            @seqs = doc2.xpath('//itemList').map do |i|
                { :stationNm => i.xpath('stationNm').inner_text,
                  :stationNo => i.xpath('stationNo').inner_text,
                  :seq => i.xpath('seq').inner_text,
                  :gpsX => i.xpath('gpsX').inner_text,
                  :gpsY => i.xpath('gpsY').inner_text
                }
            end
            
            c=0
            @seqs.each do |o|
                if o[:stationNm] == @bus_id or o[:stationNo] == @bus_id
                    c=c+1
                    @@x = o[:gpsX]
                    @@y = o[:gpsY]
                    
                end
            end
            puts c
            
            # if c==1
            #     @seqs.each do |o|
            #         if o[:stationNm] = @bus_id or o[:stationNo] == @bus_id
            #             seq1 = o[:seq]
            #             seq2 = seq1.to_i +1
            #         end
            #     end
            #     @seqs.each do |o|
            #         if o[:seq] == seq2.to_s
            #             nextS = o[:stationNm]
            #         end
            #     end
            # else
            seq = [0,0,0]
            nextS = [0,0,0]
            i=0
            j=0
                @seqs.each do |o|
                    if o[:stationNm] == @bus_id or o[:stationNo] == @bus_id
                        
                        seq_imsi = o[:seq]
                        seq[i] = seq_imsi.to_i + 1
                        i = i+1
                    end
                    
                end
                
                 @seqs.each do |o|
                    if o[:seq] == seq[j].to_s
                        nextS[j] = o[:stationNm]
                        j = j+1
                    end
                end
                
                
            # end
            
        url = "http://ws.bus.go.kr/api/rest/arrive/getArrInfoByRouteAll?serviceKey=ijltE9mKxrbB0HwVvtrvVB6kL3jPVePXQqS%2F1dNRz%2FjnTR3JMPjt1ZRLG3BOxUzRXhBbbF03lCDiBZsH2oJj2A%3D%3D&busRouteId=#{id}"
       
        doc = Nokogiri::XML(open(url))
        @items = doc.xpath('//itemList').map do |i|
         { :stNm => i.xpath('stNm').inner_text,
              :arsId => i.xpath('arsId').inner_text,
             :busRouteId => i.xpath('busRouteId').inner_text,
             :rtNm => i.xpath('rtNm').inner_text,
              :arrmsg1 => i.xpath('arrmsg1').inner_text,
              :arrmsg2 => i.xpath('arrmsg2').inner_text,
              :busType1 => i.xpath('busType1').inner_text,
              :busType2 => i.xpath('busType2').inner_text
            }
        end
        iter = 0
        @items.each do |o|
        if o[:arsId] == @bus_id or o[:stNm] == @bus_id
            iter = iter + 1
            if iter == 1
            @text = "(별)정류소명 : #{o[:stNm]}(#{o[:arsId]})\n((#{nextS[0]}방면))\n(별)버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
            else
                @text1 = "\n\n(별)정류소명 : #{o[:stNm]}(#{o[:arsId]})\n((#{nextS[1]}방면))\n(별)버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
            end
            
           
          if o[:busType1]=='0'
              bType1 = '일반버스'
          elsif o[:busType1] == '1'
              bType1 = '저상버스'
          else
              bType1 = '굴절버스'
          end
           
            if o[:busType2]=='0'
              bType2 = '일반버스'
          elsif o[:busType2] == '1'
              bType2 = '저상버스'
          else
              bType2 = '굴절버스'
            end
           
          @text2 = "첫번째 도착 차량 유형 : #{bType1}\n두번째 도착 차량 유형 : #{bType2}"
         
            
        end
      end
      if iter == 0 #버스정류장을 잘못 입력하면
         @text3 = "버스번호와 정류장을 (별)정확히(별) 다시 입력해주세요(찡긋)"
       
      end
      
      if iter == 1
          @text3 = @text
      elsif iter == 2
          @text3 = @text + @text1
      end
      
      if iter == 0
       @msg = {
              message: {
                text:  @text3
              },keyboard:{
                type: "text"
         
              }
            }
            
            render json: @msg
        else
            @msg = {
              message: {
                text:  @text3,
                message_button: {
                label: "정류장 위치 확인하기",
                url: "http://map.daum.net/link/map/#{@@y},#{@@x}"
              }
             },keyboard:{
                type: "buttons",
                buttons: ["즐겨찾기에 추가","다시 시작하기"]
              }
            }
            
            render json: @msg
        end
    else if  @info.include? ">"
         @@query = @info
         arr = @info.split(">")
         subLine = arr[0]                     #호선
         subStation = arr[1]                  #지하철역
         
        
         
         @inSubLine=URI.encode(subLine)
         @inSubStation=URI.encode(subStation)
         
         #지하철 호선 정보 xml 파일
         url = "http://swopenapi.seoul.go.kr/api/subway/55474c6a7773647231313348614b5479/xml/subwayLine/0/5/#{@inSubLine}"
          doc = Nokogiri::XML(open(url))
            @subway = doc.xpath('//row').map do |i|
             { :subwayId => i.xpath('subwayId').inner_text
        }
        end
        
        subId= @subway.first[:subwayId]
        url1 = "http://swopenapi.seoul.go.kr/api/subway/4865595641736472363266475a7344/xml/realtimeStationArrival/0/20/#{@inSubStation}"
        doc1 = Nokogiri::XML(open(url1))
        @items = doc1.xpath('//row').map do |i|
            {
                :subwayId => i.xpath('subwayId').inner_text,
                :trainLineNm => i.xpath('trainLineNm').inner_text,
                :arvlMsg2 => i.xpath('arvlMsg2').inner_text
            }
        end
         iter = 0
        @items.each do |o|
            if o[:subwayId] == subId 
                iter = iter + 1
                if iter == 1
                @text = "(별) 노선 : #{subLine}\n(별) 역명 : #{subStation}역\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter ==2
                    @text1 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 3
                    @text2 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 4
                    @text3 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                elsif iter == 5
                    @text4 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                else
                    @text5 = "\n\n[#{o[:trainLineNm]}] #{o[:arvlMsg2]}"
                end
            end
        end
        
        
       
       if iter == 0 #버스정류장을 잘못 입력하면
         @text6 = "지하철호선와 역명을 (별)정확히(별) 다시 입력해주세요(찡긋)\n(강남역 -> 강남으로 입력)"
     elsif iter == 1
          @text6 = @text
      elsif iter == 2
          @text6 = @text + @text1
      elsif iter == 3
          @text6 = @text +@text1 +@text2
     elsif iter == 4
          @text6 = @text +@text1 +@text2+@text3
     elsif iter == 5
          @text6 = @text +@text1 +@text2+@text3+@text4
      else
          @text6 = @text +@text1 +@text2+@text3+@text4+@text5
          
      end
      
      if iter == 0
       @msg = {
              message: {
                text:  @text6
              },keyboard:{
                type: "text"
         
              }
            }
            
            render json: @msg
        else
            @code = URI.encode("역")
            @msg = {
              message: {
                text:  @text6,
                message_button: {
                    label: "지하철역 위치 확인하기",
                    url: "http://map.daum.net/link/search/#{@inSubStation}#{@code}"
                }
              },keyboard:{
                type: "buttons",
          buttons: ["즐겨찾기에 추가","다시 시작하기"]
              }
            }
            
            render json: @msg
        end
        
        
    
    else
         @msg = {
              message: {
                text:  "죄송합니다(눈물)다시 시작해주세요"
              },keyboard:{
                type: "buttons",
          buttons: ["시작하기"]
              }
            }
            
            render json: @msg
    end
       
end
end
end
end
end
end
end
end
end
end
