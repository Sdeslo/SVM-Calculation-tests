#include <stdio.h>
#include <math.h>

// Define constants
#define PI 3.14159265359
#define SQRT3 1.73205080757

// Define parameters
float Vdc = 420.0; // DC link voltage
float maxModulationIndex = 1.15; // Modulation index (0 to 1)
float Ts = 0.00077; // Sampling time

// Clarke transformation
void clarkeTransform(float ia, float ib, float *i_alpha, float *i_beta) {
    *i_alpha = ia;
    *i_beta = (ia + 2 * ib) / SQRT3;
}

// Park transformation
void parkTransform(float i_alpha, float i_beta, float theta, float *i_d, float *i_q) {
    *i_d = i_alpha * cos(theta) + i_beta * sin(theta);
    *i_q = -i_alpha * sin(theta) + i_beta * cos(theta);
}

// Inverse Park transformation
void inverseParkTransform(float v_d, float v_q, float theta, float *v_alpha, float *v_beta) {
    *v_alpha = v_d * cos(theta) - v_q * sin(theta);
    *v_beta = v_d * sin(theta) + v_q * cos(theta);
}

// SVM
void svm(float v_alpha, float v_beta, float *dutyA, float *dutyB, float *dutyC) {
    float Vref = sqrt(v_alpha * v_alpha + v_beta * v_beta);
        if (Vref > maxModulationIndex) {Vref = maxModulationIndex;};
    float angle = atan2(v_beta, v_alpha);
    
    // Sector determination
    int sector = (int)(angle / (PI / 3));
    
    // Calculate T1, T2, T0
    float T1 = Ts * Vref * sin((PI / 3) - angle);
    float T2 = Ts * Vref * sin(angle);
    float T0 = Ts - T1 - T2;
    
    // Calculate duty cycles based on the sector
    switch(sector) {
        case 0:
            *dutyA = (T1 + T2 + T0 / 2) / Ts;
            *dutyB = (T2 + T0 / 2) / Ts;
            *dutyC = T0 / (2 * Ts);
            break;
        case 1:
            *dutyA = (T1 + T0 / 2) / Ts;
            *dutyB = (T1 + T2 + T0 / 2) / Ts;
            *dutyC = T0 / (2 * Ts);
            break;
        case 2:
            *dutyA = T0 / (2 * Ts);
            *dutyB = (T1 + T2 + T0 / 2) / Ts;
            *dutyC = (T2 + T0 / 2) / Ts;
            break;
        case 3:
            *dutyA = T0 / (2 * Ts);
            *dutyB = (T1 + T0 / 2) / Ts;
            *dutyC = (T1 + T2 + T0 / 2) / Ts;
            break;
        case 4:
            *dutyA = (T2 + T0 / 2) / Ts;
            *dutyB = T0 / (2 * Ts);
            *dutyC = (T1 + T2 + T0 / 2) / Ts;
            break;
        case 5:
            *dutyA = (T1 + T2 + T0 / 2) / Ts;
            *dutyB = T0 / (2 * Ts);
            *dutyC = (T1 + T0 / 2) / Ts;
            break;
    }
}

int main() {
     // Motor currents (input from the user)
    float ia, ib;

    // Prompt the user for input
    printf("Enter current ia: ");
    scanf("%f", &ia);

    printf("Enter current ib: ");
    scanf("%f", &ib);

    // Clarke transformation
    float i_alpha, i_beta;
    clarkeTransform(ia, ib, &i_alpha, &i_beta);

    // Motor position (theta) in radians
    float theta = PI / 4;

    // Park transformation
    float i_d, i_q;
    parkTransform(i_alpha, i_beta, theta, &i_d, &i_q);

    // Control algorithm here to calculate v_d and v_q
    float v_d = 1.0, v_q = 0.0; // Example values

    // Inverse Park transformation
    float v_alpha, v_beta;
    inverseParkTransform(v_d, v_q, theta, &v_alpha, &v_beta);

    // Space Vector Modulation
    float dutyA, dutyB, dutyC;
    svm(v_alpha, v_beta, &dutyA, &dutyB, &dutyC);

    // Output the duty cycles
    printf("Duty Cycle A: %f\n", dutyA);
    printf("Duty Cycle B: %f\n", dutyB);
    printf("Duty Cycle C: %f\n", dutyC);

    return 0;
}
