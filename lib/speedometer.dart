import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';
import 'package:geolocator/geolocator.dart';

class SpeedometerPage extends StatefulWidget {

  @override
  _SpeedometerPageState createState() => _SpeedometerPageState();


}

class _SpeedometerPageState extends State<SpeedometerPage> {

  double speed = 0.0;
  int secondsup =0;
  int secondsdown =0;

  int upIntervalCounter = 0;
  int downIntervalCounter = 0;


  bool reachedTen = false;
  bool reachedThirty = false;

  DefaultSegmentStyle _segmentStyle = DefaultSegmentStyle(
  enabledColor: Colors.lightBlue,
  disabledColor: Colors.white,
  );
  Geolocator geolocator = new Geolocator();
  int i = 1;
  double previousSpeed=0.0;
  List<double> speeds=[];
  double Averagespeed=0.0;


  isTen(double speed)
  {
    if(speed*(3.6) > 9.5 && speed*(3.6) < 10.5)
      {
        reachedTen =true;
        upIntervalCounter = 1;
        previousSpeed = speed;
      }
  }
  isThirty(double speed)
  {

    if(speed*(3.6) > 29.5 && speed*(3.6) < 30.5)
    {
      reachedThirty =true;
      downIntervalCounter = 1;
      previousSpeed = speed;

    }
  }


  @override
  void initState()
  {
    makeGeolocatorListenerWork();
    super.initState();
  }

  makeGeolocatorListenerWork()
  {

    geolocator.getPositionStream(LocationOptions(
        accuracy: LocationAccuracy.best, timeInterval: 500))
        .listen((position)
    {
      speeds.add(position.speed);

      if(i==4)                       //update UI every 2 sec
        {
        Averagespeed = (speeds.reduce(((a, b) => a + b)))/speeds.length;
        i=1;
        speeds.clear();


        isTen(Averagespeed);
        isThirty(Averagespeed);

        if(upIntervalCounter > 0)  //there is raising in speed after 10 Km/hr
            {
          if(previousSpeed <= Averagespeed)
          {
            upIntervalCounter++;
            previousSpeed=Averagespeed;

          }
          else
          {
            reachedTen = false;
            upIntervalCounter = 0;     // no raising in speed anymore
          }

        }
        else if(downIntervalCounter > 1)  //there is decreasing in speed after 30 Km/hr
          {

              if(previousSpeed >= Averagespeed)
              {
                downIntervalCounter++;
                previousSpeed=Averagespeed;

              }
              else
              {
                reachedThirty = false;
                downIntervalCounter = 0;     // no decreasing in speed anymore
              }

          }

        if(reachedTen && reachedThirty && upIntervalCounter > 0)
        {
          secondsup = (upIntervalCounter-1)*2;                  //every interval is 2 seconds
          reachedTen =false;
          reachedThirty = false;
          upIntervalCounter = 0;

        }
        else if (reachedTen && reachedThirty && downIntervalCounter > 0)
        {
          secondsdown = (downIntervalCounter-1)*2;               //every interval is 2 seconds
          reachedTen =false;
          reachedThirty = false;
          upIntervalCounter = 0;
        }
        setState(() {
          speed = Averagespeed*(60*60/1000);  // to get the speed in Km/h because spped attribute in position class is given in m/s
        });


      }
      else
      {
        i++;
      }

    });


  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text('Speed Of Vichle'),
            ),
            body: Center(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('Current Speed',style: TextStyle(fontSize: 24),),
                      SizedBox(height: 8,),

                      SevenSegmentDisplay(value: speed.toString(), size: 8.0,segmentStyle: _segmentStyle,backgroundColor: Colors.white,),
                      SizedBox(height: 8,),

                      Text('Km/h',style: TextStyle(fontSize: 16)),
                    ],
                  ),

                  SizedBox(height: 24,),
                  Container(
                      child: Column(
                        children: <Widget>[
                          Text('From 10 to 30',style: TextStyle(fontSize: 24)),
                          SizedBox(height: 8,),

                          SevenSegmentDisplay(value: secondsup.toString(), size: 8.0,segmentStyle: _segmentStyle,backgroundColor: Colors.white,),
                          SizedBox(height: 8,),
                          Text('seconds',style: TextStyle(fontSize: 16)),
                        ],
                      )),

                  SizedBox(height: 24,),


                  Container(
                      child: Column(
                        children: <Widget>[
                          Text('From 30 to 10',style: TextStyle(fontSize: 24)),
                          SizedBox(height: 8,),

                          SevenSegmentDisplay(value: secondsdown.toString(), size: 8.0,segmentStyle: _segmentStyle,backgroundColor: Colors.white,),
                          SizedBox(height: 8,),

                          Text('seconds',style: TextStyle(fontSize: 16)),
                        ],
                      )),

                ],
              ),
            ),

          );

  }
}

