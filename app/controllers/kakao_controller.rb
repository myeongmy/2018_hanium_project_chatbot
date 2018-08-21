require 'rubygems'
require 'rest-client'
require 'cgi'
require 'nokogiri'
require 'open-uri'

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
  
  def message
    @user_msg = params[:content]
    if @user_msg == "시작하기"
      
      @msg = {
          message: {
            text: "안녕하세요(하트뿅)\n서울시 버스 운행 정보를 드립니다~\n버스번호와 버스정류장ID를 입력해주세요\n(예 : 7737/14015)"
          },keyboard:{
            type: "text"
          }
        }
        
        render json: @msg
    else
       @info = params[:content] 
       arr = @info.split("/")
       @num = arr[0]
       @bus_id = arr[1]
       n=0
        for i in 0..@num.length
        
        if @num[i..i].numeric? == false
          n = n+1
        end
        end
        h= @num[(n-1)..@num.length]
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
        @text = "정류소명 : #{o[:stNm]}(#{o[:arsId]})\n버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
        else
            @text1 = "\n\n정류소명 : #{o[:stNm]}(#{o[:arsId]})\n버스번호 : #{o[:rtNm]}\n첫번째 도착예정시간 : #{o[:arrmsg1]}\n두번째 도착예정시간 : #{o[:arrmsg2]}"
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
     @text3 = "버스번호와 정류장을 (브이)정확히(브이) 다시 입력해주세요(찡긋)"
   
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
            text:  @text3
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
