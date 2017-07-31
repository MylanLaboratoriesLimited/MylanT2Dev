package com.qapint.app.activities;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.*;
import android.webkit.ValueCallback;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import com.qapint.app.R;

public class PresentationView extends Dialog {
    private static final int theme = android.R.style.Theme_Black_NoTitleBar_Fullscreen;
    private Context context = null;
    private PresentationWebView presentationWebView = null;
    private FrameLayout presentationViewLayout = null;
    private RelativeLayout panel = null;

    public PresentationView(Context context) {
        super(context, theme);
        this.context = context;
        presentationWebView = new PresentationWebView(getContext(), theme);
        initLayout();
        initView();
        initGestureDetector();
    }

    private void initLayout() {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setCancelable(true);

        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        presentationViewLayout = (FrameLayout) inflater.inflate(R.layout.presentation_view_layout, null);
        LinearLayout viewWrap = (LinearLayout) presentationViewLayout.findViewById(R.id.viewWrap);
        viewWrap.addView(presentationWebView);
        panel = (RelativeLayout) presentationViewLayout.findViewById(R.id.toggablePanel);
    }

    public void setOnCompleteListener(View.OnClickListener l) {
        Button btnComplete = (Button) panel.findViewById(R.id.btnComplete);
        btnComplete.setOnClickListener(l);
    }

    public void setWebClient(WebViewClient vClient) {
        presentationWebView.setWebViewClient(vClient);
    }

    private void initView() {
        setContentView(presentationViewLayout);
        setOnKeyListener(new DialogInterface.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                return !(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_UP);
            }
        });
        WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
        lp.copyFrom(getWindow().getAttributes());
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
        getWindow().setAttributes(lp);
    }

    private void initGestureDetector() {
        final GestureDetector gestureDetector = new GestureDetector(getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                int panelVisibilityState = panel.getVisibility() == View.VISIBLE ? View.INVISIBLE : View.VISIBLE;
                panel.setVisibility(panelVisibilityState);
                return true;
            }
        });
        presentationWebView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int action = event.getAction();
                if(action == MotionEvent.ACTION_DOWN){
                    if(panel.getVisibility() == View.VISIBLE){
                        panel.setVisibility(View.INVISIBLE);
                    }
                }
                return gestureDetector.onTouchEvent(event) || action == MotionEvent.ACTION_MOVE;
            }
        });
    }

    public void viewByUrl(String url) {
        presentationWebView.load("javascript: window.addEventListener('load', function(){window.document.body.style.width = window.screen.width + 'px';window.document.body.style.height = window.screen.height + 'px';});");
        presentationWebView.load(url);
        show();
    }

    public void getKpi(ValueCallback<String> resultCallback) {
        presentationWebView.load("javascript: window.invokeEvent('suspend');");
        presentationWebView.executeMethodWithName("getKPI", resultCallback);
    }

    public void clearKpi() {
        presentationWebView.executeMethodWithName("clearStorage", null);
    }
}
